
# These helpers have been archived

The last update was for 1.4. Despite the infrequency of updates to Stardew, I don't have the time any more to keep up
with the changes to the code.

I'll leave the code available, if anyone wishes to pick it up and improve / take it over.

# Stardew Valley Helpers 



Three apps:

- an app to show a villagers' schedule for a chosen day
- an app to show the artifact spots for the next day
- an app to show the foragable items for the next day

## Setup

Set up as a normal laravel project (correct permissions for `storage` etc...)

### Naming

All the file names need to match the identifiers in the files. 
  The map file names must match the identifiers in the schedule `json` files and the locations in the save file
    (location.GameLocation.name).
  The portrait and schedule file names should match. 

### Schedules

Extract the schedule xnb files from the game using [xnbnode](https://github.com/draivin/XNBNode)
  (or something similar if things have changed) and drop them into `storage/app/schedules`.

Run `./artisan locations:build` to build `storage/app/locations.json` - 
  then open this file and give each location a description.
  
### Portraits

Extract the portrait xnb files and drop them into `storage/app/portraits`.

### Maps

First, extract the map xnb files. Then you can open the tbin files with [tIDE](https://colinvella.github.io/tIDE/).
  There doesn't seem to be an export function; but you can take screenshots and get the maps that way.
  
Once they've been generated, they go in to `storage/app/maps`.
  
The following settings need setting in `.env`:

- `MAP_GRID` - the pixel size of each grid square in the map. Default is 16.
- `MAP_SCALE` - change if you want to scale the maps up or down before viewing them.
- `MAP_SIZE` - the size of the generated maps.
