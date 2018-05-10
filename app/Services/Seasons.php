<?php

namespace App\Services;

use Illuminate\Support\Collection;

class Seasons
{
    /**
     * Get a list of valid villagers
     *
     * @return Collection
     */
    public function getList()
    {
        return new Collection(['spring', 'summer', 'fall', 'winter']);
    }
}
