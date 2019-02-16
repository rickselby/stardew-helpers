<?php

namespace App\Providers;

use App\Services\Maps;
use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        View::composer('outline', function ($view) {
            $view->with('mapSizes', app()->make(Maps::class)->mapSizes());
        });
    }

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        #
    }
}
