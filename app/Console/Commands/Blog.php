<?php

namespace App\Console\Commands;

use App\Models\Stream;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use MirazMac\GoogleCSE\Scrapper;

class Blog extends Command
{
    protected $signature = 'stream:blog';
    protected $description = 'Command description';

    public function __construct()
    {
        parent::__construct();
    }

    public function handle()
    {
        $cse_account = 'partner-pub-9134522736300956:4140494421';
        $cse = new Scrapper($cse_account, []);
        $start = request()->get('start', 0);
        $spell = request()->get('spell');
        $nfpr = request()->get('nfpr');
        $params = array_filter(compact('spell', 'nfpr'));

        $keywords = DB::table('kodesaham')->select('id', 'name')->get();

        foreach ($keywords as $value_keyword) {
            try {
                $results = $cse->searchWeb('site:www.indonesia.go.id ' . $value_keyword->name, $start, 50, $params);
            } catch (\Exception $e) {
                continue;
            }

            if ($results && !empty($results->getAll())) {
                foreach ($results->getAll() as $tweet) {
                    $snippet = $tweet->getRichSnippet();
                    $source = $snippet ? str_replace("https://www.indonesia.go.id/assets/img/content_image/", "", $snippet->get('cseImage')["src"]) : '14';
                    $date = Carbon::now();
                    try {
                        $date = Carbon::parse(explode('.', $tweet->getRawContent())[0]);
                    } catch (\Exception $e) {
                    }
                    Stream::firstOrCreate(
                        ['source_id' => explode('_', $source)[0]],
                        [
                            'social' => 'web',
                            'username' => 'indonesia.go.id',
                            'content' => $tweet->getRawContent(),
                            'date' => $date,
                            'url' => $tweet->getRawURL()
                        ]
                    );
                }
            }
        }

        return 'success';
    }
}