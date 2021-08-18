<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Stream extends Model
{
    use HasFactory;

    protected $table = 'stream';
    protected $guarded = ['id'];
    protected $fillable = ['source_id', 'social', 'username', 'content', 'date', 'followers', 'url', 'reach'];
}
