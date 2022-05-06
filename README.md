# Stardew Helpers

[https://stardew.selbysaurus.me](https://stardew.selbysaurus.me)

## Running locally

You will need:

* Ruby 2.7.5
* Docker

Instructions

* Checkout the repository
* Run `bundle install`
* Run `rake init`
* Add maps as `.png` files to `data/maps`
* Add portraits as `.png` files to `data/portraits`
* Add schedules as `.json` files to `data/schedules`

See `rake -T` for other useful commands.

## Working on Vue components

Run `rake webpack:watch` to automatically recompile the vue templates when they change. 
