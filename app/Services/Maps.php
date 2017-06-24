<?php

namespace App\Services;

use Intervention\Image\Image;

class Maps
{
    const GRIDSIZE = 8;
    const CROPSIZE = 400;

    /**
     * Get a map with a marker at x,y
     *
     * @param string $name
     * @param int $x
     * @param int $y
     *
     * @return bool|Image
     */
    public function getMap(string $name, int $x, int $y)
    {
        if (!\Storage::disk('maps')->exists($this->getGeneratedPath($name, $x, $y))) {
            $this->makeMap($name, $x, $y);
        }

        if (\Storage::disk('maps')->get($this->getGeneratedPath($name, $x, $y))) {
            return \Image::make(\Storage::disk('maps')->get($this->getGeneratedPath($name, $x, $y)));
        } else {
            return false;
        }
    }

    /**
     * Get the path to the generated map
     *
     * @param string $name
     * @param int $x
     * @param int $y
     *
     * @return string
     */
    private function getGeneratedPath(string $name, int $x, int $y): string
    {
        return 'generated/'.$name.'-'.$x.'-'.$y.'.png';
    }

    /**
     * Create the map from the original
     *
     * @param string $name
     * @param int $x
     * @param int $y
     */
    private function makeMap(string $name, int $x, int $y)
    {
        if (!\Storage::disk('maps')->exists($name . '.png')) {
            return false;
        }

        $img = \Image::make(\Storage::disk('maps')->get($name . '.png'));

        // Add some kind of marker at $x, $y (8px per square)
        $this->addMarker($img, $x, $y);
        $this->crop($img, $x, $y);

        // Save to the generated path
        \Storage::disk('maps')->put($this->getGeneratedPath($name, $x, $y), $img->encode());

    }

    /**
     * Add the marker to the map at the correct location
     *
     * @param Image $image
     * @param int $x
     * @param int $y
     */
    private function addMarker(Image $image, int $x, int $y)
    {
        $marker = \Image::make(\Storage::get('marker.png'));

        $xOffset = ($marker->width() - self::GRIDSIZE) / 2;
        $yOffset = ($marker->height() - self::GRIDSIZE) / 2;
        $image->insert($marker, 'top-left', ($x * self::GRIDSIZE) - $xOffset, ($y * self::GRIDSIZE) - $yOffset);
    }

    /**
     * Crop the image to the right size
     *
     * @param Image $image
     * @param int $x
     * @param int $y
     */
    private function crop(Image $image, int $x, int $y)
    {
        $image->crop(self::CROPSIZE, self::CROPSIZE, $this->getCropOffset($x), $this->getCropOffset($y));
    }

    /**
     * Get the crop offset to center the image on the marker
     *
     * @param int $tile
     *
     * @return int
     */
    private function getCropOffset(int $tile): int
    {
        return (($tile + 0.5) * self::GRIDSIZE) - (self::CROPSIZE / 2);
    }
}