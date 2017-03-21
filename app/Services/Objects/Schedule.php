<?php

namespace App\Services\Objects;

class Schedule
{
    /**
     * @var string
     */
    private $schedule;
    /**
     * @var string
     */
    private $extra;

    public function __construct(string $schedule, string $extra = '')
    {
        $this->schedule = $schedule;
        $this->extra = $extra;
    }

    public function __get($property) {
        if (property_exists($this, $property)) {
            return $this->$property;
        }
    }

    public function __toString()
    {
        return $this->schedule.' : '.$this->extra;
    }
}