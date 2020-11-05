<template>
  <section>
    <b-table
      :data="weatherStations"
      :columns="columns"
      :selected.sync="selectedWeatherStation"
      focusable
    >
    </b-table>
    <weather-station-chart
      :weather-station="selectedWeatherStation"
      :refresh="refresh"
    >
    </weather-station-chart>
  </section>
</template>

<script>
import allWeatherStations from '../graphql/query/allWeatherStations.graphql'
import WeatherStationChart from './WeatherStationChart'

export default {
  components: {
    WeatherStationChart
  },
  data () {
    return {
      weatherStations: [],
      selectedWeatherStation: null,
      columns: [
        { field: "identifier", label: "identifier" },
        { field: "name", label: "name" },
        { field: "latitude", label: "latitude" },
        { field: "longitue", label: "longitue" },
      ],
      intervalFn: null,
      refresh: false
    }
  },
  computed: {
    weatherStationIdentifier () {
      return this.selectedWeatherStation ? this.selectedWeatherStation.identifier : null
    }
  },
  watch: {
    selectedWeatherStation () {
      this.refresh = !this.refresh
    }
  },
  apollo: {
    init: {
      query: allWeatherStations,
      fetchPolicy: 'network-only',
      update (data) {
        this.weatherStations = data.allWeatherStations.nodes
        this.selectedWeatherStation = this.selectedWeatherStation ? this.weatherStations.find(ws => ws.identifier === this.selectedWeatherStation.identifier) : null
        this.refresh = !this.refresh
      }
    }
  },
  mounted () {
    this.intervalFn = setInterval(function(){
      this.$apollo.queries.init.refetch()
    }.bind(this), 3000);
  }
}
</script>

<style>

</style>
