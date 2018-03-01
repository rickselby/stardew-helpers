<template>
    <div>
        <div class="row center-block panel">
            <div class="wood-border">
                <div class="text-center">
                    <img v-for="name in villagers" class="portrait" :src="'portrait/'+name" :alt="name" :title="name"
                         v-on:click="villager=name"
                         v-bind:class="villager===name ? 'portrait-active' : ''" />
                </div>
                <div class="text-center" id="calendars">
                    <template v-for="season in seasons">
                        <div class="calendar-container">
                            <h4>{{ capitalizeFirstLetter(season) }}</h4>
                            <span v-bind:id="season" class="calendar">
                                <img src="calendar.png" v-bind:usemap="'#'+season+'Map'" />
                                <div class="calendar-marker"></div>
                            </span>
                            <map v-bind:name="season+'Map'">
                                <area shape="rect" v-for="day in days"
                                      v-bind:coords="getCoords(day)"
                                      @click="setDay(day, season)"
                                      :alt="day" :title="day" />
                            </map>
                        </div>
                    </template>
                </div>
            </div>
        </div>

        <div class="row center-block panel">
            <div class="wood-border">
                <div class="loading text-muted" id="loading">
                    <span class="glyphicon glyphicon-refresh glyphicon-animate"></span>
                </div>
                <div class="row row-grid" id="possibilities">
                    <div class="col-xs-12" v-if="possibilities.length == 0">
                        Select a villager and a date, and their possible schedules will appear here.
                    </div>
                    <h4 class="col-xs-12 text-center" v-if="possibilities.length !== 0">
                        {{ selectedString }}
                    </h4>
                    <template v-for="(poss, index) in filterPossibilities(possibilities)">
                        <div class="panel" v-bind:class="getPossClasses(poss)">
                            <div class="bulletin">
                                <div class="panel-heading">
                                    <h4>
                                        {{ poss.extra }}
                                        {{ poss.doubleRain ? '(equal chance of either)' : '' }}
                                    </h4>
                                </div>
                                <template v-if="poss.doubleRain">
                                    <div class="col-xs-6" style="border-right: 1px solid black">
                                        <schedule v-bind:schedule="schedules[poss.schedule]"></schedule>
                                    </div>
                                    <div class="col-xs-6">
                                        <schedule v-bind:schedule="schedules[poss.doubleRainSchedule]"></schedule>
                                    </div>
                                </template>
                                <template v-else>
                                    <schedule v-bind:schedule="schedules[poss.schedule]"></schedule>
                                </template>
                            </div>
                        </div>
                        <div class="clearfix visible-sm-block" v-if="((index + 1) % 2) === 0"></div>
                        <div class="clearfix visible-md-block" v-if="((index + 1) % 3) === 0"></div>
                        <div class="clearfix visible-lg-block" v-if="((index + 1) % 4) === 0"></div>
                    </template>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
    var schedules = {};
    var possibilities = [];
    export default {
        data: function() {
            return {
                villagers: villagers,
                seasons: seasons,
                days: days,
                schedules: [],
                possibilities: [],
                villager: '',
                season: '',
                day: '',
                selectedString: '',
            }
        },
        watch: {
            villager: function() {
                this.loadSchedules();
            },
            season: function() {
                this.loadSchedules();
            },
            day: function() {
                this.loadSchedules();
            }
        },
        methods: {
            getCoords: function(day) {
                var dayOfWeek = ((day - 1) % 7);
                var row = Math.floor((day - 1) / 7);
                return '' + ((dayOfWeek * 32) + 9) + ',' +
                    ((row * 32) + 39) + ',' +
                    ((dayOfWeek * 32) + 41) + ',' +
                    ((row * 32) + 71);
            },
            setVillager: function(villager) {
                this.villager=villager;
            },
            setDay: function(day, season) {
                this.season = season;
                this.day = day;
                $('.calendar-marker').hide();
                $('#'+season+' .calendar-marker').show()
                    .css('left', (7 + (((day - 1) % 7) * 32)))
                    .css('top', (37 + (Math.floor((day - 1) / 7) * 32)));
            },
            loadSchedules: function() {
                var vm = this;

                $('#possibilities').each(function() {
                    $(this).fadeTo(300, 0);
                });
                $('#loading').show();

                $.ajax({
                    url: postURL,
                    data: {
                        'villager': this.villager,
                        'season': this.season,
                        'day': this.day
                    },
                    dataType: 'json',
                    type: 'post',
                    error: function (XMLHttpRequest, textStatus, errorThrown) {

                        $('#loading').hide();
                        $('#possibilities').promise().done(function() {

                            vm.schedules = [];
                            vm.possibilities = [];

                            $('#possibilities').each(function () {
                                $(this).fadeTo(300, 1);
                            });

                        });
                    },
                    success: function (data) {

                        $('#loading').hide();
                        $('#possibilities').promise().done(function() {

                            vm.selectedString = vm.villager + ': '
                                + vm.ordinalSuffix(vm.day) + ' of '
                                + vm.capitalizeFirstLetter(vm.season);

                            vm.schedules = data.schedules;
                            vm.possibilities = data.possibilities;

                            $('#possibilities').each(function () {
                                $(this).fadeTo(300, 1);
                            });

                        });
                    }
                });
            },
            getPossClasses: function(poss) {
                if (poss.doubleRain) {
                    return ['col-lg-6', 'col-md-8', 'col-sm-12'];
                } else {
                    return ['col-lg-3', 'col-md-4', 'col-sm-6'];
                }
            },
            capitalizeFirstLetter: function(string) {
                return string.charAt(0).toUpperCase() + string.slice(1);
            },
            filterPossibilities: function(possibilities) {
                var possList = [];
                for (var poss of possibilities) {
                    if (possList.length === 0) {
                        possList.push(poss);
                    } else {
                        if (poss.rain && possList[possList.length - 1].rain) {
                            possList[possList.length - 1].doubleRain = true;
                            possList[possList.length - 1].doubleRainSchedule = poss.schedule;
                        } else {
                            possList.push(poss);
                        }
                    }
                }
                return possList;
            },
            ordinalSuffix: function(val) {
                var j = val % 10,
                    k = val % 100;
                if (j == 1 && k != 11) {
                    return val + "st";
                }
                if (j == 2 && k != 12) {
                    return val + "nd";
                }
                if (j == 3 && k != 13) {
                    return val + "rd";
                }
                return val + "th";
            }
        }
    }
</script>
