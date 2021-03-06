<?php

namespace App\Services;

use App\Services\Objects\Schedule;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class Schedules
{
    /** @var Collection */
    private $schedule;

    /** @var string */
    private $villager;

    /** @var bool */
    private $isMarried = false;

    /** @var Schedule[] */
    private $possibilities = [];

    /** @var int */
    private $priority;

    private $dowMap = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    public function __construct(string $villager)
    {
        $this->villager = $villager;
        $this->schedule = $this->readFile();
    }

    /**
     * Set this villager as married to the player
     */
    public function setMarried(): void
    {
        $this->isMarried = true;
    }

    /**
     * Get the schedule possibilities for a given date
     */
    public function getFor(string $season, int $dayOfMonth): array
    {
        $this->possibilities = [];

        $this->firstPass($season, $dayOfMonth);
        $this->secondPass($season);
        $this->sortPossibilities();

        $schedules = [];
        foreach ($this->possibilities as $possibility) {
            $schedules[$possibility->schedule] = $this->schedule->get($possibility->schedule);
        }

        return [
            'possibilities' => $this->possibilities,
            'schedules' => $schedules
        ];
    }

    /**
     * First pass - get the possible schedule names
     */
    private function firstPass(string $season, int $dayOfMonth): void
    {
        $this->priority = 1;
        if ($this->isMarried) {
            $this->married($dayOfMonth);
        } else {
            $this->unmarried($season, $dayOfMonth);
        }
    }

    /**
     * Get a schedule for a married villager
     */
    private function married(int $dayOfMonth): void
    {
        $dayOfWeek = $this->getDayOfWeek($dayOfMonth);
        /**
         * NPC.cs line 2082
         * if (this.name.Equals("Penny") && (str.Equals("Tue") || str.Equals("Wed") || str.Equals("Fri"))
         * || (this.name.Equals("Maru") && (str.Equals("Tue") || str.Equals("Thu"))
         * || this.name.Equals("Harvey") && (str.Equals("Tue") || str.Equals("Thu"))))
         */
        if (($this->villager == 'Penny'  && ($dayOfWeek == 'Tue' || $dayOfWeek == 'Wed' || $dayOfWeek == 'Fri'))
            || ($this->villager == 'Maru'   && ($dayOfWeek == 'Tue' || $dayOfWeek == 'Thu'))
            || ($this->villager == 'Harvey' && ($dayOfWeek == 'Tue' || $dayOfWeek == 'Thu'))
        ) {
            $this->setRegular('marriageJob');
            return;
        }

        // marriage_[day] will run if NOT raining, so add it as a possibility
        if ($this->schedule->has('marriage_'.$dayOfWeek)) {
            $this->addPossibility('noschedule', 'Raining');
            $this->setRegular('marriage_'.$dayOfWeek);
        } else {
            $this->setRegular('noschedule');
        }
    }

    /**
     * Get a schedule for an unmarried villager
     */
    private function unmarried(string $season, int $dayOfMonth): void
    {
        if ($this->schedule->has($season.'_'.$dayOfMonth)) {
            $this->setRegular($season.'_'.$dayOfMonth);
            return;
        }

        // Some days have alternatives if you have enough hearts with the villager
        for ($h = 13; $h > 0; $h--) {
            if ($this->schedule->has($dayOfMonth.'_'.$h)) {
                $this->addPossibility($dayOfMonth.'_'.$h, 'At least '.$h.' hearts with '.$this->villager);
            }
        }

        if ($this->schedule->has($dayOfMonth)) {
            $this->setRegular($dayOfMonth);
            return;
        }

        // If you've unlocked the bus, this will be Pam every day...!
        if ($this->villager == 'Pam') {
            $this->addPossibility('bus', 'If the bus is unlocked');
        }

        // Raining will be 50/50 choice if there are two
        $this->addPossibility('rain', 'If Raining', true);
        if ($this->schedule->has('rain2')) {
            // Same priority as the other rain one
            $this->priority--;
            $this->addPossibility('rain2', 'If Raining', true);
        }

        $dayOfWeek = $this->getDayOfWeek($dayOfMonth);

        // Some days have alternatives if you have enough hearts with the villager
        // Pretty sure this one is never used, but it's coded...
        for ($h = 13; $h > 0; $h--) {
            if ($this->schedule->has($season.'_'.$dayOfWeek.'_'.$h)) {
                $this->addPossibility($season.'_'.$dayOfWeek.'_'.$h, 'At least '.$h.' hearts with '.$this->villager);
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
            return;
        }

        // Some days have alternatives if you have enough hearts with the villager
        // Pretty sure this one is never used, but it's coded...
        // This is how this was intended (I think), but the game is actually searching for [season]_spring_[hearts]
        // which doesn't exist anywhere. So, remove it.
        /*
        for ($h = 13; $h > 0; $h--) {
            if ($this->schedule->has('spring_'.$dayOfWeek.'_'.$h)) {
                $this->addPossibility('spring_'.$dayOfWeek.'_'.$h, 'At least '.$h.' hearts with '.$this->villager);
            }
        }
        */

        if ($this->schedule->has('spring')) {
            $this->setRegular('spring');
            return;
        }

        $this->setRegular('noschedule');
        return;
    }

    /**
     * Second pass on the schedules, handle changes in-schedule
     */
    private function secondPass(string $season): void
    {
        $this->checkForGoto($season);
        $this->checkForNot();
        // Re-check - things might have changed with the NOT check?
        $this->checkForGoto($season);
        $this->skipNotsAfterGoto();

        $this->checkForDuplicates();

        $this->checkLocations();
    }

    /**
     * Check the schedules for a GOTO keyword
     */
    private function checkForGoto(string $season): void
    {
        foreach ($this->possibilities as $possibility) {
            $schedule = $this->schedule->get($possibility->schedule);
            if (substr($schedule[0], 0, 4) === 'GOTO') {
                $goto = explode(' ', $schedule[0]);
                if (Str::lower($goto[1]) == 'season') {
                    // Match "GOTO season" and convert to the current season
                    $goto[1] = $season;
                }

                if ($this->schedule->has($goto[1])) {
                    $possibility->updateSchedule($goto[1]);
                } else {
                    $possibility->updateSchedule('spring');
                }
            }
        }
    }

    /**
     * Check the schedules for a NOT keyword
     */
    private function checkForNot(): void
    {
        foreach ($this->possibilities as $possibility) {
            $schedule = $this->schedule->get($possibility->schedule);
            if (substr($schedule[0], 0, 3) === 'NOT') {
                $not = explode(' ', $schedule[0]);
                if ($not[1] == 'friendship') {
                    $this->incrementPriorities($possibility->priority + 1);
                    
                    // Add a new option for spring if the conditional is true
                    $this->possibilities[] = new Schedule('spring', $possibility->priority + 1, $possibility->extra);

                    // Amend this schedule as a NOT schedule
                    $possibility->updateExtra('Not at '.$not[3].' hearts with '.$not[2]);
                }

                // Clear the NOT from the schedule so we don't parse it again later
                array_shift($schedule);
                $this->schedule->offsetSet($possibility->schedule, $schedule);
            }
        }
    }

    /**
     * If there was a NOT then a GOTO, we might be at the same NOT again, so...
     * See: Penny:23, Sam:23, Abigail:25
     */
    private function skipNotsAfterGoto(): void
    {
        foreach ($this->possibilities as $possibility) {
            $schedule = $this->schedule->get($possibility->schedule);
            if (substr($schedule[0], 0, 3) === 'NOT') {
                // Clear the NOT from the schedule so we don't parse it again later
                array_shift($schedule);
                $this->schedule->offsetSet($possibility->schedule, $schedule);
            }
        }
    }

    /**
     * Check for duplicate schedules next to each other and combine the reasons
     */
    private function checkForDuplicates(): void
    {
        $this->sortPossibilities();
        $lastPossibility = null;
        foreach ($this->possibilities as $k => $possibility) {
            $updateLast = true;

            if ($lastPossibility) {
                if ($possibility->schedule == $lastPossibility->schedule) {
                    $lastPossibility->updateExtra(implode(' / ', [$lastPossibility->extra, $possibility->extra]));
                    unset($this->possibilities[$k]);
                    $updateLast = false;
                }
            }

            if ($updateLast) {
                $lastPossibility = $possibility;
            }
        }
    }

    /**
     * Check for inaccessable locations and replace as required
     */
    private function checkLocations(): void
    {
        // We're not replacing the schedules here, just adding alternatives where required
        foreach ($this->possibilities as $possibility) {
            // Get the schedule listed
            $schedule = $this->schedule->get($possibility->schedule);
            $scheduleChanged = false;

            // Step through each action of the schedule
            foreach ($schedule as $k => $action) {
                $actionParts = explode(' ', $action);

                // Is the action taking us somewhere that might not be open yet?
                if (in_array($actionParts[1], ['JojaMart', 'Railroad', 'CommunityCenter'])) {
                    // Check for a [location]_Replacement in the schedule
                    // For whatever reason, the code doesn't use CommunityCenter_Replacement even though some villagers
                    // have it set. See NPC.cs, line 2653
                    if (in_array($actionParts[1], ['JojaMart', 'Railroad'])
                        && $this->schedule->has($actionParts[1].'_Replacement')
                    ) {
                        $replaceParts = explode(' ', $this->schedule->get($actionParts[1].'_Replacement')[0]);

                        // Rebuild the action with the original time, but the rest of the details from the replacement
                        $schedule[$k] = implode(
                            ' ',
                            array_merge([$actionParts[0]], $replaceParts)
                        );

                        // Mark the schedule as changed (with the name of the replaced location)
                        $scheduleChanged = $actionParts[1];
                    } else {
                        // No replacement - the whole schedule might switch

                        $this->incrementPriorities($possibility->priority + 1);

                        $this->possibilities[] = new Schedule(
                            $this->schedule->has('default') ? 'default' : 'spring',
                            $possibility->priority,
                            'If '.$actionParts[1].' is not available'
                        );
                        $possibility->incrementPriority();

                        // No changes to save, and stop processing this schedule
                        $scheduleChanged = false;
                        break;
                    }
                }
            }

            if ($scheduleChanged) {
                // Save an "alternative" schedule before the current one
                $this->incrementPriorities($possibility->priority + 1);
                $this->schedule->offsetSet($possibility->schedule.'_alt', $schedule);
                $this->possibilities[] = new Schedule(
                    $possibility->schedule.'_alt',
                    $possibility->priority,
                    'If '.$scheduleChanged.' is not available'
                );
                $possibility->incrementPriority();
            }
        }
    }

    /**
     * Read the schedule file for the given villager
     */
    public function readFile(): Collection
    {
        $file = json_decode(Storage::disk('schedules')->get($this->villager.'.json'), true);

        foreach ($file['content'] as $key => $value) {
            $file['content'][$key] = explode('/', $value);
        }

        return new Collection($file['content']);
    }

    /**
     * Get a day of week string from the day of the month
     */
    private function getDayOfWeek(int $dayOfMonth): string
    {
        return $this->dowMap[$dayOfMonth % 7];
    }

    /**
     * Add a possible schedule to the list
     */
    private function addPossibility(string $schedule, string $extra, bool $rain = false): void
    {
        $this->possibilities[] = new Schedule($schedule, $this->priority++, $extra, $rain);
    }

    /**
     * Set text for the regular schedule
     */
    private function setRegular(string $schedule): void
    {
        $this->addPossibility($schedule, 'Regular Schedule');
    }

    /**
     * Increment all priorities equal to or greater than the given priority
     */
    private function incrementPriorities(int $priority): void
    {
        foreach ($this->possibilities as $possibility) {
            if ($possibility->priority >= $priority) {
                $possibility->incrementPriority();
            }
        }
    }

    /**
     * Sort the possibilities by priority
     */
    private function sortPossibilities(): void
    {
        usort($this->possibilities, function ($a, $b) {
            return $a->priority - $b->priority;
        });
    }
}
