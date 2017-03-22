<?php

namespace App\Services;

use Illuminate\Support\Collection;

class Villagers
{
    /**
     * Get a list of valid villagers
     *
     * @return Collection
     */
    public function getList()
    {
        return \Cache::rememberForever('villagers-list', function() {
            $files = new Collection();
            foreach(\Storage::disk('schedules')->files() AS $file) {
                if (\File::extension($file) == 'yaml') {
                    $files->push(\File::name($file));
                }
            }
            return $files;
        });
    }
}