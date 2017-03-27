<template>
    <div>
        <div class="row center-block panel">
            <div class="interiorpanel">
                <div class="row row-grid">
                    <div class="col-sm-4">
                        <select id="villager" name="villager" class="form-control" v-on:change="loadSchedules">
                            <option value="">Select a villager...</option>
                            <option v-for="villager in villagers" v-bind:value="villager">{{ villager }}</option>
                        </select>
                    </div>
                    <div class="col-sm-4">
                        <select id="season" name="season" class="form-control" v-on:change="loadSchedules">
                            <option value="">Select a season...</option>
                            <option v-for="season in seasons" v-bind:value="season">{{ capitalizeFirstLetter(season) }}</option>
                        </select>
                    </div>
                    <div class="col-sm-4">
                        <select id="day" name="day" class="form-control" v-on:change="loadSchedules">
                            <option value="">Select a day...</option>
                            <option v-for="day in days" v-bind:value="day">{{ day }}</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <div class="row center-block panel">
            <div class="interiorpanel">
                <div class="loading text-muted" id="loading">
                    <span class="glyphicon glyphicon-refresh glyphicon-animate"></span>
                </div>
                <div class="row row-grid" id="possibilities">
                    <div class="col-xs-12" v-if="possibilities.length == 0">
                        Select a villager and a date, and their possible schedules will appear here.
                    </div>
                    <template v-for="(poss, index) in filterPossibilities(possibilities)">
                        <div class="panel" v-bind:class="getPossClasses(poss)">
                            <div class="bulletinpanel">
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
            }
        },
        methods: {
            loadSchedules: function() {
                var vm = this;

                $('#possibilities').each(function() {
                    $(this).fadeTo(300, 0);
                });
                $('#loading').show();

                $.ajax({
                    url: postURL,
                    data: {
                        'villager': $('#villager').val(),
                        'season': $('#season').val(),
                        'day': $('#day').val()
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
            filterPossibilities(possibilities) {
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
            }
        }
    }
</script>
