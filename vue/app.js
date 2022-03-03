
require('bootstrap');

import Vue from 'vue';
window.Vue = Vue;

Vue.component('calendar', require('./calendar.vue').default);
Vue.component('forage', require('./forage.vue').default);
