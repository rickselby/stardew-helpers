<?php

namespace App\Services;

use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Facades\Image;

class Villagers
{
    /**
     * Get a list of valid villagers
     */
    public function getList(): Collection
    {
        return Cache::rememberForever('villagers-list', function () {
            $files = new Collection();
            foreach (Storage::disk('schedules')->files() as $file) {
                if (File::extension($file) == 'json') {
                    $files->push(\File::name($file));
                }
            }
            return $files;
        });
    }

    /**
     * Get the portrait for this villager
     *
     * @return bool|\Intervention\Image\Image
     */
    public function getPortrait(string $villager)
    {
        if (Storage::disk('portraits')->get($villager.'.png')) {
            return Image::make(Storage::disk('portraits')->get($villager . '.png'));
        } else {
            return false;
        }
    }
}
