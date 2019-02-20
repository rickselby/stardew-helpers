<?php

namespace App\Services;

use Illuminate\Contracts\Filesystem\FileNotFoundException;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;

class Locations
{
    private $filename = 'locations.json';
    /**
     * @var Villagers
     */
    private $villagers;

    public function __construct(Villagers $villagers)
    {
        $this->villagers = $villagers;
    }

    /**
     * Get a list of valid locations
     */
    public function getList(): Collection
    {
        try {
            $file = Storage::get($this->filename);
            return new Collection(json_decode($file));
        } catch (FileNotFoundException $e) {
            return new Collection();
        }
    }

    private function setList(Collection $list): void
    {
        Storage::put($this->filename, $list->toJson());
    }

    /**
     * (Re-)build the locations file with all possible locations
     */
    public function buildFile(): void
    {
        $list = $this->getList();

        foreach ($this->villagers->getList() as $villager) {
            $villagerList = new Collection($list->get($villager) ?? []);

            $schedule = (new Schedules($villager))->readFile();
            foreach ($schedule as $name => $possibility) {
                foreach ($possibility as $step) {
                    $steps = explode(' ', $step);
                    if (preg_match('/\d?\d{3}/', $steps[0])) {
                        $location = implode(' ', array_slice($steps, 1, 3));

                        if (!$villagerList->has($location)) {
                            $villagerList->offsetSet($location, "");
                        }
                    }
                }
                // Make sure we add the replacement locations too!
                if (preg_match('/_Replacement/', $name)) {
                    $steps = explode(' ', $step);
                    $location = implode(' ', array_slice($steps, 0, 3));
                    if (!$villagerList->has($location)) {
                        $villagerList->offsetSet($location, "");
                    }
                }
            }

            $list->offsetSet($villager, $villagerList);
        }

        $this->setList($list);
    }

    /**
     * Parse a list of schedules and replace the locations with names
     * @param $villager
     * @param $schedules
     */
    public function parseLocations($villager, &$schedules): void
    {
        $list = new Collection($this->getList()->get($villager) ?? []);

        foreach ($schedules as &$schedule) {
            foreach ($schedule as $id => &$step) {
                $steps = explode(' ', $step);
                $location = implode(' ', array_slice($steps, 1, 3));

                // Check for broken steps (Shane, plz)
                // steps[1] should be the map name, NOT a number...
                if (!is_numeric($steps[1])) {
                    $step = [
                        'time' => $steps[0],
                        'location' => $list->get($location) ?? '??',
                        'map' => $steps[1],
                        'x' => $steps[2],
                        'y' => $steps[3],
                        'facing' => $steps[4],
                        'sprite' => $steps[5] ?? '',
                    ];
                } else {
                    unset($schedule[$id]);
                }
            }
        }
    }
}
