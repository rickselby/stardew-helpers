#!/bin/sh

set -e

env=${APP_ENV:-production}

if [ "$env" != "local" ]; then
    echo "Caching configuration..."
    (cd /code && php artisan config:cache && php artisan route:cache)
fi

echo "Running the app..."
exec php-fpm
