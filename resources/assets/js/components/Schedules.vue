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
                <div class="row row-grid" id="possibilities">
                    <div class="col-xs-12" v-if="possibilities.length == 0">
                        Select a villager and a date, and their possible schedules will appear here.
                    </div>
                    <div class="col-sm-6 col-md-4 col-lg-3 panel" v-for="poss in possibilities">
                        <div class="bulletinpanel">
                            <div class="panel-heading">
                                <h4>{{ poss.extra }}</h4>
                            </div>
                            <ul class="list-group">
                                <li class="list-group-item" v-for="step in filterSteps(schedules[poss.schedule])">
                                    {{ formatTime(step.time) }}:
                                    {{ step.location }}
                                </li>
                            </ul>
                        </div>
                    </div>
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
                        vm.schedules = [];
                        vm.possibilities = [];
                    },
                    success: function (data) {

                        $('#possibilities').each(function() {
                            $(this).fadeTo(300, 0);
                        });

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
            capitalizeFirstLetter: function(string) {
                return string.charAt(0).toUpperCase() + string.slice(1);
            },
            filterSteps(steps) {
                var stepList = [];
                for (var step of steps) {
                    if (stepList.length === 0) {
                        stepList.push(step);
                    } else {
                        if (stepList[stepList.length - 1].location !== step.location) {
                            stepList.push(step);
                        }
                    }
                }
                return stepList;
            },
            formatTime(time) {
                // Pad left with a zero, if necessary
                time = ('0' + time).slice(-4);
                console.log(time)
                return time.slice(0,2) + ':' + time.slice(-2);
            }
        }
    }
</script>
