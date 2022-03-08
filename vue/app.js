
require('bootstrap');

import axios from 'axios';
window.axios = axios;

import Vue from 'vue';
window.Vue = Vue;

Vue.component('calendar', require('./calendar.vue').default);
Vue.component('forage', require('./forage.vue').default);
if (process.env["NODE_ENV"] === 'development') {
    Vue.component('locations', require('./locations.vue').default);
}
