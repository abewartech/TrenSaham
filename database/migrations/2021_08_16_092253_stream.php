<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class Stream extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('stream', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('source_id')->nullable();
            $table->string('social');
            $table->string('username')->nullable();
            $table->longText('content');
            $table->string('date')->nullable();
            $table->integer('followers')->nullable();
            $table->string('url')->nullable();
            $table->integer('reach')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('stream');
    }
}
