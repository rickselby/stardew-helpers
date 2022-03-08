<template>
  <div>
    <div class="row panel">
      <div class="wood-border">
        <div class="text-center mb-3">
          <div v-for="(data, name) in people" class="position-relative d-inline-block">
            <img class="portrait" :src="'/portrait/'+name" :alt="name" :title="name"
                 v-on:click="person=name"
                 v-bind:class="person===name ? 'portrait-active' : ''" />
            <span class="position-absolute translate-middle badge bg-info rounded-pill"
                  style="top: 20%; left: 80%">{{ missing(name) }}</span>
          </div>
        </div>
      </div>
    </div>
    <div class="panel">
      <div class="wood-border">
        <table class="table">
          <template v-for="(locations, map) in places">
            <location v-for="(name, coords) in locations" :key="`${person}-${map}-${coords}`"
                      v-bind:person="person" v-bind:map="map" v-bind:coords="coords" v-bind:name="name">
            </location>
          </template>
        </table>
      </div>
    </div>
  </div>
</template>

<script>

import location from './location.vue';

export default {
  name: "locations",
  components: {
    location
  },
  props: {
    people: Object,
  },

  data() {
    return {
      person: null,
    }
  },
  computed: {
    places() {
      return this.people[this.person];
    }
  },
  methods: {
    missing(person) {
      let missing = 0;
      for (let map of Object.keys(this.people[person])) {
        for (let coords of Object.keys(this.people[person][map])) {
          if (this.people[person][map][coords] === "") {
            missing++;
          }
        }
      }
      return missing;
    },
  }
}
</script>
