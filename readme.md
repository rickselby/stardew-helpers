
# Stardew Valley Calendar 

An app to show a villagers' schedule for a chosen day.

## Setup

Extract the schedule xnb files from the game and drop them into `storage/app/schedules`. 

## Notes

We use an old version of `symfony/yaml` (3.1) due to the keys in the schedule YAML files;
some keys are (e.g.) `11_6` and `symfony/yaml` 3.2+ will parse this as `116`.

