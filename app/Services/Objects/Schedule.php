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
    /**
     * @var int
     */
    private $priority;

    public function __construct(string $schedule, int $priority, string $extra = '')
    {
        $this->schedule = $schedule;
        $this->extra = $extra;
        $this->priority = $priority;
    }

    public function __get($property)
    {
        if (property_exists($this, $property)) {
            return $this->$property;
        }
    }

    /**
     * @param $priority
     * @return $this
     */
    public function updateSchedule(string $schedule)
    {
        $this->schedule = $schedule;
        return $this;
    }

    /**
     * @param $priority
     * @return $this
     */
    public function incrementPriority()
    {
        $this->priority++;
        return $this;
    }

    public function updateExtra(string $extra)
    {
        $this->extra = $extra;
        return $this;
    }

    public function __toString()
    {
        return $this->schedule.' | '.$this->priority.' | '.$this->extra;
    }
}