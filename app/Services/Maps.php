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
            return;
        }

        $img = \Image::make(\Storage::disk('maps')->getDriver()->getAdapter()->applyPathPrefix($name . '.png'));

        // Add some kind of marker at $x, $y (8px per square)
        $this->addMarker($img, $x, $y);

        if (config('map.scale') != 1) {
            $this->scale($img);
        }
        $this->crop($img, $x, $y);

        // Save to the generated path
        \Storage::disk('maps')->put($this->getGeneratedPath($name, $x, $y), $img->encode('png'));
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
        $mapGrid = config('map.grid');

        $marker = \Image::make(\Storage::get('marker.png'));

        $xOffset = ($marker->width() - $mapGrid) / 2;
        $yOffset = ($marker->height() - $mapGrid) / 2;
        $image->insert($marker, 'top-left', ($x * $mapGrid) - $xOffset, ($y * $mapGrid) - $yOffset);
    }

    /**
     * Scale the image as appropriate
     *
     * @param Image $image
     */
    private function scale(Image $image)
    {
        $image->heighten($image->height() * config('map.scale'));
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
        $mapSize = config('map.size');
        // Expanding the image first will give us a transparent background all around
        $image->resizeCanvas($mapSize, $mapSize, 'center', true);
        $image->crop(
            $mapSize,
            $mapSize,
            $this->getCropOffset($x) + ($mapSize / 2),
            $this->getCropOffset($y) + ($mapSize / 2)
        );
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
        return (($tile + 0.5) * config('map.grid') * config('map.scale')) - (config('map.size') / 2);
    }
}
