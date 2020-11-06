<template>
  <section v-if="station">
    <h1>Weather Station Identifier: {{ station.identifier }}</h1>
    <div class="small">
      <line-chart :chart-data="station.currentChartData" :refresh="refresh"></line-chart>
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
      station: {
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
        console.log('refresh', this.station ? this.station.currentChartData.labels.slice(-1) : '')
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
