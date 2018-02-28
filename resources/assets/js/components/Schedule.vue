<template>
    <ul class="list-group">
        <div v-for="step in filterSteps(schedule)">
            <li class="list-group-item">
                {{ formatTime(step.time) }}:
                <a href="#mapModal" data-toggle="modal" data-target="#mapModal" v-bind:data-map="getMap(step)">
                    {{ step.location }}
                </a>
            </li>
        </div>
    </ul>
</template>

<script>
    export default {
        props: [
            'schedule'
        ],
        methods: {
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
            getMap(step) {
                return step.map + '/' + step.x + '/' + step.y;
            },
            formatTime(time) {
                // Pad left with a zero, if necessary
                time = ('0' + time).slice(-4);
                return time.slice(0,2) + ':' + time.slice(-2);
            },
        }
    }
</script>
