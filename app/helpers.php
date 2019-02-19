<?php

/**
 * Awful fix for  https://github.com/laravel/internals/issues/634  but what can you do...
 * HOPEFULLY this can be removed in the near future and mix() can be used as normal.
 *
 * @param string $path
 * @param string $manifestDirectory
 *
 * @return \Illuminate\Support\HtmlString|string
 */
function mix_except_in_tests($path, $manifestDirectory = '')
{
    if (app()->runningUnitTests()) {
        return '';
    }

    return mix($path, $manifestDirectory);
}
