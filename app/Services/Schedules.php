<?php

namespace App\Services;

use Illuminate\Support\Collection;
use Illuminate\Support\Str;
use Symfony\Component\Yaml\Yaml;

class Schedules
{
    /** @var Collection */
    private $schedule;

    /** @var string */
    private $villager;

    /** @var bool */
    private $isMarried = false;

    private $regular = [];
    private $raining = [];
    private $hearts = [];
    private $other = [];

    public function __construct(string $villager)
    {
        $this->villager = $villager;
        $this->schedule = $this->readFile($villager);
    }

    /**
     * Set this villager as married to the player
     */
    public function setMarried()
    {
        $this->isMarried = true;
    }

    /**
     * Get the schedule possibilities for a given date
     *
     * @param string $season
     * @param int $dayOfMonth
     */
    public function getFor(string $season, int $dayOfMonth)
    {
        $this->firstPass($season, $dayOfMonth);
        $this->secondPass($season);
    }

    /**
     * First pass - get the possible schedule names
     *
     * @param string $season
     * @param int $dayOfMonth
     */
    private function firstPass(string $season, int $dayOfMonth)
    {
        if ($this->isMarried) {
            $this->married($dayOfMonth);
        } else {
            $this->unmarried($season, $dayOfMonth);
        }

    }

    /**
     * Get a schedule for a married villager
     *
     * @param int        $dayOfMonth
     */
    private function married(int $dayOfMonth)
    {
        $dayOfWeek = $this->getDayOfWeek($dayOfMonth);
        /**
         * NPC.cs line 2082
         * if (this.name.Equals("Penny") && (str.Equals("Tue") || str.Equals("Wed") || str.Equals("Fri"))
         * || (this.name.Equals("Maru") && (str.Equals("Tue") || str.Equals("Thu"))
         * || this.name.Equals("Harvey") && (str.Equals("Tue") || str.Equals("Thu"))))
         */
        if (
            ($this->villager == 'Penny'  && ($dayOfWeek == 'Tue' || $dayOfWeek == 'Wed' || $dayOfWeek == 'Fri'))
            || ($this->villager == 'Maru'   && ($dayOfWeek == 'Tue' || $dayOfWeek == 'Thu'))
            || ($this->villager == 'Harvey' && ($dayOfWeek == 'Tue' || $dayOfWeek == 'Thu'))
        ) {
            $this->setRegular('marriageJob');
            return;
        }

        // marriage_[day] will run if NOT raining, so add it as a possibility
        if ($this->schedule->has('marriage_'.$dayOfWeek)) {
            $this->setRegular('marriage_'.$dayOfWeek);
            $this->raining[] = 'noschedule';
        } else {
            $this->setRegular('noschedule');
        }
    }

    /**
     * Get a schedule for an unmarried villager
     *
     * @param string $season
     * @param int $dayOfMonth
     */
    private function unmarried(string $season, int $dayOfMonth)
    {
        if ($this->schedule->has($season.'_'.$dayOfMonth)) {
            $this->setRegular($season.'_'.$dayOfMonth);
            return;
        }

        // Some days have alternatives if you have enough hearts with the villager
        for ($h = 13; $h > 0; $h--) {
            if ($this->schedule->has($dayOfMonth.'_'.$h)) {
                $this->hearts[] = $dayOfMonth.'_'.$h;
            }
        }

        if ($this->schedule->has($dayOfMonth)) {
            $this->setRegular($dayOfMonth);
            return;
        }

        // If you've unlocked the bus, this will be Pam every day...!
        if ($this->villager == 'Pam') {
            $this->other[] = 'bus';
        }

        // Raining will be 50/50 choice if there are two
        $this->raining[] = 'rain';
        if ($this->schedule->has('rain2')) {
            $this->raining[] = 'rain2';
        }

        $dayOfWeek = $this->getDayOfWeek($dayOfMonth);

        // Some days have alternatives if you have enough hearts with the villager
        // Pretty sure this one is never used, but it's coded...
        for ($h = 13; $h > 0; $h--) {
            if ($this->schedule->has($season.'_'.$dayOfWeek.'_'.$h)) {
                $this->hearts[] = $season.'_'.$dayOfWeek.'_'.$h;
            }
        }

        if ($this->schedule->has($season.'_'.$dayOfWeek)) {
            $this->setRegular($season.'_'.$dayOfWeek);
            return;
        }

        if ($this->schedule->has($dayOfWeek)) {
            $this->setRegular($dayOfWeek);
            return;
        }

        if ($this->schedule->has($season)) {
            $this->setRegular($season);
            return;
        }

        if ($this->schedule->has('spring_'.$dayOfWeek)) {
            $this->setRegular('spring_'.$dayOfWeek);
        }

        // Some days have alternatives if you have enough hearts with the villager
        // Pretty sure this one is never used, but it's coded...
        for ($h = 13; $h > 0; $h--) {
            if ($this->schedule->has('spring_'.$dayOfWeek.'_'.$h)) {
                $this->hearts[] = 'spring_'.$dayOfWeek.'_'.$h;
            }
        }

        if ($this->schedule->has('spring')) {
            $this->setRegular('spring');
            return;
        }

        $this->setRegular('noschedule');
        return;
    }

    /**
     * Second pass on the schedules, handle changes in-schedule
     *
     * @param string $season
     */
    private function secondPass(string $season)
    {
        foreach(['regular', 'raining', 'hearts', 'other'] AS $key) {
            $this->checkForGoto($key, $season);
            $this->checkForNot($key);
            // Re-check - things might have changed with the NOT check?
            $this->checkForGoto($key, $season);
        }
    }

    /**
     * Check the schedules for a GOTO keyword
     *
     * @param string $key
     * @param string $season
     */
    private function checkForGoto(string $key, string $season)
    {
        $scheduleKeys = [];
        // Work through each possible schedule in the given list
        // Build a new array of schedules to replace it with
        foreach($this->{$key} AS $scheduleKey) {

            $schedule = $this->schedule->get($scheduleKey);
            if (substr($schedule[0], 0, 4) === 'GOTO') {
                $goto = explode(' ', $schedule[0]);
                if (Str::lower($goto[1]) == 'season') {
                    // Match "GOTO season" and convert to the current season
                    $goto[1] = $season;
                }

                if ($this->schedule->has($goto[1])) {
                    $scheduleKeys[] = $goto[1];
                } else {
                    $scheduleKeys[] = 'spring';
                }
             } else {
                $scheduleKeys[] = $scheduleKey;
            }
        }
        $this->{$key} = $scheduleKeys;
    }

    /**
     * Check the schedules for a NOT keyword
     *
     * @param string $key
     */
    private function checkForNot(string $key)
    {
        $scheduleKeys = [];
        // Work through each possible schedule in the given list
        // Build a new array of schedules to replace it with
        foreach($this->{$key} AS $scheduleKey) {

            $schedule = $this->schedule->get($scheduleKey);
            if (substr($schedule[0], 0, 3) === 'NOT') {
                $not = explode(' ', $schedule[0]);
                if ($not[1] == 'friendship') {
                    // TODO: flag why this is an "other" schedule
                    $this->other[] = $scheduleKey;
                    $scheduleKeys[] = 'spring';
                } else {
                    $scheduleKeys[] = $scheduleKey;
                }

                // Clear the NOT from the schedule so we don't parse it again in the Other schedules list
                array_shift($schedule);
                $this->schedule->offsetSet($scheduleKey, $schedule);
            } else {
                $scheduleKeys[] = $scheduleKey;
            }
        }
        $this->{$key} = $scheduleKeys;
    }

    /**
     * Read the schedule file for the given villager
     *
     * @param string $villager
     *
     * @return Collection
     */
    private function readFile(string $villager)
    {
        $file = Yaml::parse(\Storage::disk('schedules')->get($villager.'.yaml'));

        foreach($file['content'] AS $key => $value) {
            $file['content'][$key] = explode('/', $value);
        }

        return new Collection($file['content']);
    }

    /**
     * Get a day of week string from the day of the month
     *
     * @param int $dayOfMonth
     *
     * @return string
     */
    private function getDayOfWeek(int $dayOfMonth): string
    {
        $dowMap = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        return $dowMap[$dayOfMonth % 7];
    }

    /**
     * Set the regular schedule
     *
     * @param $schedule
     */
    private function setRegular($schedule)
    {
        $this->regular = [$schedule];
    }


}