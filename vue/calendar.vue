<template>
  <div>
    <div class="row panel">
      <div class="wood-border">
        <div class="text-center">
          <img v-for="name in people" class="portrait" :src="'/portrait/'+name" :alt="name" :title="name"
               v-on:click="person=name"
               v-bind:class="person===name ? 'portrait-active' : ''" />
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
      person: null,
      people: [],
    }
  },
  created() {
    this.loadPeople();
  },
  methods: {
    loadPeople() {
      axios.get('/api/people')
          .then(response => {
            this.people = response.data;
          })
          .catch(() => {
            console.log('Failed to load people?')
          });
    }
  }
}
</script>
