<template>
  <tr>
    <th>{{ map }}</th>
    <td>{{ coords }}</td>
    <td>
      <input v-model="locationName" />
    </td>
    <td>
      <img v-bind:src="'/map/' + map + '/' + coords.replace(' ', '/')" />
    </td>
  </tr>
</template>

<script>
export default {
  name: "location",
  props: {
    coords: String,
    map: String,
    person: String,
    name: String
  },
  data() {
    return {
      locationName: this.name,
    }
  },
  watch: {
    locationName: function (val) {
      let form = new FormData();
      form.append('person', this.person);
      form.append('map', this.map);
      form.append('coords', this.coords);
      form.append('name', val);

      axios.post('/api/location', form)
          .catch(error => {
            console.log(error);
          });
    }
  }
}
</script>
