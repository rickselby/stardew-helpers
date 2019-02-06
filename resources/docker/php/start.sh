#!/bin/sh

set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

if [ "$env" != "local" ]; then
    echo "Caching configuration..."
    (cd /code && php artisan config:cache && php artisan route:cache)
fi

if [ "$role" = "app" ]; then

    echo "Migrating and updating permissions..."
    (cd /code && php artisan migrate --force && php artisan permission:update)
    echo "Running the app..."
    exec php-fpm

elif [ "$role" = "queue" ]; then

    echo "Running the queue..."
    php /code/artisan queue:work --verbose --tries=3 --timeout=90

elif [ "$role" = "scheduler" ]; then

    echo "Running the scheduler..."
    while [ true ]
    do
      php /code/artisan schedule:run --verbose --no-interaction &
      sleep 60
    done

else
    echo "Could not match the container role \"$role\""
    exit 1
fi
