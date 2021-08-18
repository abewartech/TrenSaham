<?php

namespace App\Console\Commands;

use App\Models\Stream;
use Carbon\Carbon;
use Illuminate\Console\Command;
use MirazMac\GoogleCSE\Scrapper;

class Blog extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'stream:blog';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $cse_account = 'partner-pub-9134522736300956:4140494421';

        //connect sosmed
        $cse = new Scrapper($cse_account, []);
        $start = isset($_GET['start']) ? (int) $_GET['start'] : 0;
        $spell = isset($_GET['spell']) ? (int) $_GET['spell'] : null;
        $nfpr = isset($_GET['nfpr']) ? (int) $_GET['nfpr'] : null;
        $params = [];
        if ($spell) {
            $params['spell'] = $spell;
        } elseif ($nfpr) {
            $params['nfpr'] = $nfpr;
        }

        $results = $cse->searchWeb('site:www.indonesia.go.id ' . 'saham', $start, 50, $params);

        if (!empty($results->getAll())) {
            foreach ($results->getAll() as $key => $tweet) {
                $snippet = $tweet->getRichSnippet();
                $source = ($snippet) ? str_replace("https://www.indonesia.go.id/assets/img/content_image/", "", $snippet->get('cseImage')["src"]) : '14';
                Stream::firstOrCreate(
                    ['source_id' => explode('_', $source)[0]],
                    ['social' => 'web', 'username' => 'indonesia.go.id',
                        'content' => $tweet->getRawContent(), 'date' => Carbon::parse(explode('.', $tweet->getRawContent())[0]), 'url' => $tweet->getRawURL()]
                );
            }
        }

        return 'success';
    }
}
