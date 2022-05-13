<template>
  <div>
    <div class="row panel">
      <div class="wood-border">
        <div class="text-center mb-3">
          <img v-for="name in people" class="portrait" :src="'/portrait/'+name" :alt="name" :title="name"
               v-on:click="person=name"
               v-bind:class="person===name ? 'portrait-active' : ''" />
        </div>
        <div class="text-center" id="calendars">
          <template v-for="season_name in seasons">
            <div class="calendar-container">
              <h4>{{ capitalizeFirstLetter(season_name) }}</h4>
              <div v-bind:id="season_name" class="calendar">
                <img src="/img/calendar.png" v-bind:usemap="'#'+season_name+'Map'" alt="Calendar" />
                <div class="calendar-marker"
                     v-bind:style="calendarMarkerPosition"
                     v-bind:class="season===season_name ? 'd-block' : 'd-none'"
                ></div>
              </div>
              <map v-bind:name="season_name+'Map'">
                <area shape="rect" v-for="day in days" :alt="day" :title="day"
                      v-bind:coords="getCoords(day)"
                      @click="setDay(day, season_name)" />
              </map>
            </div>
          </template>
        </div>
      </div>
    </div>

    <div class="row panel" v-if="schedules.length !== 0">
      <div class="wood-border">
        <h3>How to read the schedules</h3>
        <p>
          Read the panels from left to right. The first panel that applies should be the
          villager's schedule for the day. There many be alternatives for rain, for buildings
          being unavailable, or based on friendship that will override the regular schedule for
          a day.
        </p>
        <p>
          The times shown are when the villager will leave their previous location and head
          to the listed location.
        </p>
      </div>
    </div>

    <div class="row panel">
      <div class="wood-border">
        <div class="d-flex justify-content-center" v-if="loading">
          <div class="spinner-border" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>
        <div class="row" v-if="!loading">
          <div class="col-12" v-if="schedules.length === 0">
            Select a villager and a date, and their possible schedules will appear here.
          </div>
          <h4 class="col-12 text-center" v-if="schedules.length !== 0">
            {{ selected }}
          </h4>
          <template v-for="schedule in possibilities">
            <div class="panel route-panel" v-bind:class="schedulePanelClasses(schedule)">
              <div class="bulletin">
                <div class="panel-heading">
                  <h4>
                    {{ schedule.notes }}
                    <span v-if="schedule.doubleRain">
                      (equal chance of either)
                    </span>
                  </h4>
                </div>
                <div class="row">
                  <div class="list-group list-group-flush" v-bind:class="scheduleClasses(schedule)">
                    <template v-for="route in schedule.routes">
                        <button type="button" class="list-group-item" data-bs-toggle="modal" data-bs-target="#mapModal" v-on:click="setRoute(route)">
                          {{ formatTime(route.time) }}:
                          {{ route.name }}
                        </button>
                    </template>
                  </div>
                  <div class="list-group list-group-flush" v-bind:class="scheduleClasses(schedule)" v-if="schedule.doubleRain">
                    <template v-for="route in schedule.doubleRainRoutes">
                      <button type="button" class="list-group-item" data-bs-toggle="modal" data-bs-target="#mapModal" v-on:click="setRoute(route)">
                        {{ formatTime(route.time) }}:
                        {{ route.name }}
                      </button>
                    </template>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>

    <div class="modal" tabindex="-1" id="mapModal">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-body">
            <img v-bind:src="mapPath" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "calendar",

  data() {
    return {
      day: null,
      days: [...Array(28).keys()].map(i => i + 1),
      loading: false,
      person: null,
      people: [],
      route: null,
      schedules: [],
      season: null,
      seasons: ['spring', 'summer', 'fall', 'winter'],
    }
  },
  computed: {
    calendarMarkerPosition() {
      return {
        left: (7 + (((this.day - 1) % 7) * 32)) + 'px',
        top: (37 + (Math.floor((this.day - 1) / 7) * 32)) + 'px',
      }
    },
    mapPath() {
      console.log(this.route);
      if (this.route === null) {
        return '';
      }

      return '/' + [ 'map', this.route.map, this.route.x, this.route.y ].join('/')
    },
    possibilities() {
      let possibilities = [];
      for (const poss of this.schedules) {
        if (possibilities.length === 0) {
          possibilities.push(poss);
        } else {
          if (poss.rain && possibilities[possibilities.length - 1].rain) {
            possibilities[possibilities.length - 1].doubleRain = true;
            possibilities[possibilities.length - 1].doubleRainRoutes = poss.routes;
          } else {
            possibilities.push(poss);
          }
        }
      }
      return possibilities;
    },
    selected() {
      return this.person + ': '
          + this.ordinalSuffix(this.day) + ' of '
          + this.capitalizeFirstLetter(this.season);
    },
  },
  created() {
    this.loadPeople();
  },
  methods: {
    capitalizeFirstLetter: function (string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    },
    formatTime(time) {
      time = ('0' + time).slice(-4);
      return time.slice(0,2) + ':' + time.slice(-2);
    },
    getCoords: function (day) {
      let dayOfWeek = ((day - 1) % 7),
          row = Math.floor((day - 1) / 7);
      return '' + ((dayOfWeek * 32) + 9) + ',' +
          ((row * 32) + 39) + ',' +
          ((dayOfWeek * 32) + 41) + ',' +
          ((row * 32) + 71);
    },
    loadPeople() {
      axios.get('/api/people')
          .then(response => {
            this.people = response.data;
          })
          .catch(() => {
            console.log('Failed to load people?')
          });
    },
    loadSchedules() {
      this.schedules = [];

      let form = new FormData();
      form.append('person', this.person);
      form.append('season', this.season);
      form.append('day', this.day);

      axios.post('/api/schedules', form)
          .then(response => {
            this.schedules = response.data;
          })
          .catch(error => {
            // TODO: show the error
            console.log(error);
          });
    },
    ordinalSuffix: function (val) {
      let j = val % 10,
          k = val % 100;
      if (j === 1 && k !== 11) {
        return val + "st";
      }
      if (j === 2 && k !== 12) {
        return val + "nd";
      }
      if (j === 3 && k !== 13) {
        return val + "rd";
      }
      return val + "th";
    },
    scheduleClasses(schedule) {
      if (schedule.doubleRain) {
        return ['col-6', 'two-rains']
      } else {
        return []
      }
    },
    schedulePanelClasses(schedule) {
      if (schedule.doubleRain) {
        return [ 'col-12', 'col-md-12', 'col-lg-8', 'col-xl-6']
      } else {
        return [ 'col-12', 'col-md-6', 'col-lg-4', 'col-xl-3']
      }
    },
    setDay: function (day, season) {
      this.season = season;
      this.day = day;
    },
    setRoute: function (route) {
      this.route = route;
    }
  },
  watch: {
    person: function () {
      this.loadSchedules();
    },
    season: function () {
      this.loadSchedules();
    },
    day: function () {
      this.loadSchedules();
    }
  },
}
</script>
