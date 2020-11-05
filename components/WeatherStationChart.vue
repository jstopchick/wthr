<template>
  <section v-if="weatherStation">
    <h1>Weather Station Identifier: {{ weatherStation.identifier }}</h1>
    <div class="small">
      <line-chart :chart-data="weatherStation.currentChartData" :refresh="refresh"></line-chart>
    </div>
  </section>
</template>

<script>
  import LineChart from './LineChart.vue'

  export default {
    components: {
      LineChart
    },
    props: {
      weatherStation: {
        type: Object,
        default: null
      },
      refresh: {
        type: Boolean,
        default: false
      }
    },
    data () {
      return {
      }
    },
    mounted () {
    },
    methods: {
    },
    watch: {
      refresh () {
        console.log('refresh', this.weatherStation ? this.weatherStation.currentChartData.labels.slice(-1) : '')
      }
    }
  }
</script>

<style>
  .small {
    max-width: 600px;
    margin:  150px auto;
  }
</style>
