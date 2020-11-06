<template>
  <section>
    <b-table
      :data="stations"
      :columns="columns"
      :selected.sync="selectedStation"
      focusable
    >
    </b-table>
    <station-chart
      :station="selectedStation"
      :refresh="refresh"
    >
    </station-chart>
  </section>
</template>

<script>
import allStations from '../graphql/query/allStations.graphql'
import StationChart from './StationChart'
import {interval} from 'rxjs'

export default {
  components: {
    StationChart
  },
  data () {
    return {
      stations: [],
      selectedStation: null,
      columns: [
        { field: "identifier", label: "identifier" },
        { field: "name", label: "name" },
        { field: "latitude", label: "latitude" },
        { field: "longitude", label: "longitude" },
      ],
      intervalFn: null,
      refresh: false,
      timer: null
    }
  },
  computed: {
  },
  watch: {
    selectedStation () {
      this.refresh = !this.refresh
    }
  },
  apollo: {
    init: {
      query: allStations,
      fetchPolicy: 'network-only',
      update (data) {
        this.stations = data.allStations.nodes
        this.selectedStation = this.selectedStation ? this.stations.find(ws => ws.identifier === this.selectedStation.identifier) : null
        this.refresh = !this.refresh
      }
    }
  },
  mounted () {
    this.timer = interval(1000);

    this.timer.subscribe(() => this.$apollo.queries.init.refetch())
  }
}
</script>

<style>

</style>
