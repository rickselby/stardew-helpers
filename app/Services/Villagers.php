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
        return \Cache::rememberForever('villagers-list', function () {
            $files = new Collection();
            foreach (\Storage::disk('schedules')->files() as $file) {
                if (\File::extension($file) == 'yaml') {
                    $files->push(\File::name($file));
                }
            }
            return $files;
        });
    }

    /**
     * Get the portrait for this villager
     *
     * @param string $villager
     *
     * @return bool|\Intervention\Image\Image
     */
    public function getPortrait(string $villager)
    {
        if (\Storage::disk('portraits')->get($villager.'.png')) {
            return \Image::make(\Storage::disk('portraits')->get($villager . '.png'));
        } else {
            return false;
        }
    }
}
