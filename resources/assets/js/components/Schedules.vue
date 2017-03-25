<template>
    <div>
        <div class="row center-block panel">
            <div class="interiorpanel">
                <div class="row row-grid">
                    <div class="col-sm-4 has-error">
                        <select id="villager" name="villager" class="form-control" v-on:change="loadSchedules">
                            <option value="">Select a villager...</option>
                            <option v-for="villager in villagers" v-bind:value="villager">{{ villager }}</option>
                        </select>
                    </div>
                    <div class="col-sm-4 has-error">
                        <select id="season" name="season" class="form-control" v-on:change="loadSchedules">
                            <option value="">Select a season...</option>
                            <option v-for="season in seasons" v-bind:value="season">{{ season }}</option>
                        </select>
                    </div>
                    <div class="col-sm-4 has-error">
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
                                <li class="list-group-item" v-for="step in schedules[poss.schedule]">
                                    {{ step.time }}:
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
                        vm.schedules = data.schedules;
                        vm.possibilities = data.possibilities;
                    }
                });
            }
        }
    }
</script>
