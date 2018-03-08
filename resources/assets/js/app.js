
/**
 * First we will load all of this project's JavaScript dependencies which
 * includes Vue and other libraries. It is a great starting point when
 * building robust, powerful web applications using Vue and Laravel.
 */

require('./bootstrap');

window.Vue = require('vue');

Vue.component('possibilities', require('./components/Possibilities.vue'));
Vue.component('schedule', require('./components/Schedule.vue'));

window.addEventListener('load', function () {
    const app = new Vue({
        el: '#app'
    });
});

require('./artifacts');

$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name=csrf-token]').attr("content"),
    }
});
