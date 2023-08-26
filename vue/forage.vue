<template>
  <div>
    <div v-if="!fileSupport" class="alert alert-danger">Fatal Error: Could not load the File & FileReader APIs</div>

    <div id="forage-maps" class="row center-block panel maps" v-if="maps.length > 0">
      <div class="wood-border">
        <h2>Results</h2>
        <div id="forage-out">
          <div v-for="map in maps">
            <h3>{{ map.map }}</h3>
            <ul>
              <li v-for="spot in map.spots">
                {{ spotName(spot) }}
              </li>
            </ul>
            <div class="fullMap">
              <img class="base" v-bind:src="'/map/' + mapReference(map.map)" />
              <img v-for="spot in map.spots" src="/img/marker.png"
                   v-bind:title="spotName(spot)" data-bs-toggle="tooltip"
                   v-bind:style="markerStyle(map.map, spot.x, spot.y)" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <div id="forage-input-container" class="row panel" v-if="fileSupport">
      <div class="wood-border">
        <h2>Save File</h2>
        <p>
          Select a save file to check:
          <input type="file" id="forage_file_select" @change="onFileChange" />
        </p>
        <div id="forage-input-advice">
          <p>
            Please use the full save file named with your farmer's name and a 9-digit ID number
            (e.g. <code>Fred_148093307</code>);
            do not use the <code>SaveGameInfo</code> file as it does not contain all the necessary information.
          </p>
          <p>
            Default save file locations are:
          </p>
          <ul>
            <li>Windows: <code>%AppData%\StardewValley\Saves\</code></li>
            <li>Mac OSX &amp; Linux: <code>~/.config/StardewValley/Saves/</code></li>
          </ul>
          <p>
            We do not upload your file; all processing is done on your own machine.
          </p>
        </div>
      </div>
    </div>

    <div class="row center-block panel">
      <div class="wood-border">
        <h3>About this app</h3>
        <p>
          Your save file contains the locations of forageable itesm for the next day.
          This app reads those items spots and displays them.
        </p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "forage",
  data() {
    return {
      farmType: null,
      maps: [],
      mapSizes: {},
      lookFor: [
        16, // Wild Horseradish
        18, // Daffodil
        20, // Leek
        22, // Dandelion
        88, // Coconut
        90, // Cactus Fruit
        257, // Morel
        259, // Fiddlehead Fern
        281, // Chanterelle
        283, // Holly
        372, // Clam
        392, // Nautilus Shell
        393, // Coral
        394, // Rainbow Shell
        396, // Spice Berry
        397, // Sea Urchin
        398, // Grape
        402, // Sweet Pea
        404, // Common Mushroom
        406, // Wild Plum
        408, // Hazelnut
        410, // Blackberry
        420, // Red Mushroom
        414, // Crystal Fruit
        418, // Crocus
        718, // Cockle
        719, // Mussel
        723, // Oyster
      ],
    };
  },
  computed: {
    fileSupport() {
      return window.File && window.FileReader;
    },
  },
  created() {
    this.loadMapSizes();
  },
  methods: {
    findForage(xml) {
      for (const location of xml.querySelectorAll('locations > GameLocation')) {
        let mapName = location.querySelector(':scope > name').textContent,
            forage = [];

        for (const item of location.querySelectorAll('objects > item')) {
          let itemID = parseInt(item.querySelector('parentSheetIndex').textContent),
              bigCraftable = item.querySelector('bigCraftable').textContent === 'true';
          if (this.lookFor.includes(itemID) && !bigCraftable) {
            let x = item.querySelector('tileLocation > X').textContent,
                y = item.querySelector('tileLocation > Y').textContent,
                itemName = item.querySelector('name').textContent;

            forage.push({'x': x, 'y': y, 'name': itemName});
          }
        }

        for (const item of location.querySelectorAll('terrainFeatures > item')) {
          let whichForageCrop = item.querySelector('whichForageCrop'),
              isForageCrop = whichForageCrop ? whichForageCrop.textContent === '1' : false;

          if (isForageCrop) {
            let x = item.querySelector('key X').textContent,
                y = item.querySelector('key Y').textContent,
                itemName = 'Spring Onion';

            forage.push({'x': x, 'y': y, 'name': itemName});
          }
        }

        if (forage.length > 0) {
          this.maps.push({
            map: mapName,
            spots: forage,
          });
        }
      }
    },
    loadMapSizes() {
      axios.get('/api/map-sizes')
          .then(response => {
            this.mapSizes = response.data;
          })
          .catch(() => {
            console.log('Failed to load map sizes?')
          });
    },
    mapReference(map) {
      if (map === 'Farm') {
        switch (this.farmType) {
          case '1':
            return 'Farm_Fishing';
          case '2':
            return 'Farm_Forage';
          case '3':
            return 'Farm_Mining';
          case '4':
            return 'Farm_Combat';
          case '5':
            return 'Farm_FourCorners';
          case '6':
            return 'Farm_Island';
          default:
            return 'Farm';
        }
      } else {
        return map;
      }
    },
    markerStyle(map, x, y) {
      let mapCoords = this.mapSizes[map];

      return 'left: ' + (x / mapCoords.x * 100) + '%; ' +
          'top: ' + (y / mapCoords.y * 100) + '%; ' +
          'width: ' + (1 / mapCoords.x * 100) + '%; ';
    },
    readFile(file) {
      let reader = new FileReader();

      reader.onload = (e) => {
        let xml = (new DOMParser).parseFromString(e.target.result, 'text/xml');
        this.farmType = xml.getElementsByTagName('whichFarm')[0].textContent;
        this.findForage(xml);
      }

      reader.readAsText(file);
    },
    spotName(spot) {
      return '(' + spot.x + ', ' + spot.y + '): ' + spot.name;
    },
    onFileChange(e) {
      let files = e.target.files;
      if (!files.length) {
        return;
      }
      this.farmType = null;
      this.maps = [];
      this.readFile(files[0]);
    }
  },
  updated: function () {
    this.$nextTick(() => {
      var tooltipTriggerList = [].slice.call(this.$el.querySelectorAll('[data-bs-toggle="tooltip"]'))
      var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new global.bootstrap.Tooltip(tooltipTriggerEl)
      });
    })
  }
}
</script>
