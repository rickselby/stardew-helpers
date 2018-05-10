<?php

namespace App\Services;

use Intervention\Image\Image;

class Maps
{
    // Size of pixel grid on original maps
    const GRIDSIZE = 16;

    /**
     * Get a full map
     *
     * @param string $name
     *
     * @return bool|Image
     */
    public function getFullMap(string $name)
    {
        if (!\Storage::disk('maps')->exists($name . '.png')) {
            return false;
        } else {
            return \Image::make(\Storage::disk('maps')->get($name . '.png'));
        }
    }

    /**
     * Get a list of map sizes (in grid squares)
     */
    public function mapSizes()
    {
        $maps = collect();

        foreach (\Storage::disk('maps')->allFiles() as $file) {
            if (substr($file, -4) == '.png') {
                $imageSize = getimagesize(\Storage::disk('maps')->path($file));

                $map = substr($file, 0, -4);
                $maps->put($map, [
                    'x' => (int) ceil($imageSize[0] / self::GRIDSIZE),
                    'y' => (int) ceil($imageSize[1] / self::GRIDSIZE),
                ]);
            }
        }

        return $maps;
    }
}
