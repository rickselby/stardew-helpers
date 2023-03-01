# Stardew Helpers

[https://stardew.selbysaurus.me](https://stardew.selbysaurus.me)

## Running locally

You will need:

* Ruby
* Docker

Instructions

* Checkout the repository
* Run `bundle install`
* Add maps as `.png` files to `data/maps`
* Add portraits as `.png` files to `data/portraits`
* Add schedules as `.json` files to `data/schedules`
* Run `rake init`

See `rake -T` for other useful commands.

## Working on Vue components

Run `rake webpack:watch` to automatically recompile the vue templates when they change. 
