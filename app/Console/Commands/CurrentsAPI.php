<?php

namespace App\Console\Commands;

use App\Models\Stream;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CurrentsAPI extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'stream:currents';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Stream Currentsapi';

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
        $keywords = DB::table('kodesaham')->select('id', 'name')->get();

        foreach ($keywords as $key => $value_keyword) {
            $language = "msa";
            $api_key = "vssulUe2ZBPf5ee_30P5QuKP3lRNWESyCOmP7fKoBa0HQUuN";

            $ch = curl_init();

            curl_setopt($ch, CURLOPT_URL, "https://api.currentsapi.services/v1/search?keywords=" . $value_keyword->name . "&language=" . $language);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");

            $headers = array();
            $headers[] = "cache-control: no-cache";
            $headers[] = "Authorization:" . $api_key;
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

            $result = curl_exec($ch);
            if (curl_errno($ch)) {
                echo 'Error:' . curl_error($ch);
            }
            curl_close($ch);
            $response = json_decode($result, true);

            //save data
            if ($response['status'] === "ok") {
                foreach ($response['news'] as $key => $tweet) {
                    Stream::firstOrCreate(
                        ['source_id' => $tweet["id"]],
                        ['social' => 'web', 'username' => $tweet["author"], 'keyword_id' => $value_keyword->id, 'content' => $tweet["description"] ?: $tweet["title"], 'date' => Carbon::parse($tweet["published"]),
                            'url' => $tweet["url"]]
                    );
                }
            }
        }
    }
}
