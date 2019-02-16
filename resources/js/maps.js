/**
 * Get the styles for a marker
 *
 * @param map
 * @param x
 * @param y
 *
 * @returns {string}
 */
export function getMarkerPositionStyle(map, x, y)
{
    let mapCoords = mapSizes[map];

    return 'left: ' + (x / mapCoords.x * 100) + '%; ' +
        'top: ' + (y / mapCoords.y * 100) + '%; ' +
        'width: ' + (1 / mapCoords.x * 100) + '%; '
        ;
}

/**
 * Get the map name for display
 *
 * @param map
 * @returns {*}
 */
export function getMapName(map) {
    let maps = {
        BusStop: 'Bus Stop',
        Woods: 'Hidden Forest'
    };

    if (maps.hasOwnProperty(map)) {
        return maps[map];
    } else {
        return map;
    }
}

/**
 * Get the correct map for the farm for the current save
 *
 * @param map
 * @param farmType
 * @returns {*}
 */
export function getMapReference(map, farmType) {
    if (map === 'Farm') {
        switch (farmType) {
            case '0':
                return 'Farm';
            case '1':
                return 'FarmFishing';
            case '2':
                return 'FarmForage';
            case '3':
                return 'FarmMining';
            case '4':
                return 'FarmCombat';
            default:
                return 'WHAT';
        }
    } else {
        return map;
    }
}
