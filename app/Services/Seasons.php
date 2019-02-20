<?php

namespace App\Services;

use Illuminate\Support\Collection;

class Seasons
{
    /**
     * Get a list of valid villagers
     */
    public function getList(): Collection
    {
        return new Collection(['spring', 'summer', 'fall', 'winter']);
    }
}
