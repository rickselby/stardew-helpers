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
      days: [...Array(27).keys()].map(i => i + 1),
      loading: false,
      person: null,
      people: [],
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
    selected() {
      return this.person + ': '
          + this.ordinalSuffix(this.day) + ' of '
          + this.capitalizeFirstLetter(this.season);
    }
  },
  created() {
    this.loadPeople();
  },
  methods: {
    capitalizeFirstLetter: function (string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
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
            console.log(response.data);
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
    setDay: function (day, season) {
      this.season = season;
      this.day = day;
    },
  },
  watch: {
    person: function() {
      this.loadSchedules();
    },
    season: function() {
      this.loadSchedules();
    },
    day: function() {
      this.loadSchedules();
    }
  },
}
</script>
