<template>
  <div :key="'sgm-group'" class="card mt-5">
    <div class="card-header">
      <h5 class="card-title">SGM Groups</h5>
    </div>
    <div class="card-body">
      <div class="row">
        <div class="col">
          <ProgressTable :data-obj="sgmGroups" />
        </div>
        <div class="col">
          <PieChart v-if="loaded" :chartdata="chartData" :options="chartOptions"></PieChart>
        </div>
      </div>
      <div class="row">
        <div class="card-header">
          <h5 class="card-title">Blank Breakdown</h5>
        </div>
        <div>
          <CountryTable :data-obj="blankStats" :first-header="'Survey Progress'" :second-header="'Count'" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import PieChart from './charts/PieChart';
import CountryTable from './CountryTable';
import ProgressTable from './ProgressTable';

export default {
  name: 'SgmGroups',

  data: () => ({
    loaded: false,
    chartOptions: {
        legend: {
          display: true
        },
        responsive: true,
        maintainAspectRatio: false
      },
    chartData: {},
    sgmGroups: {},
    blankStats: {},
  }),

  props: {
      countryName: String
  },

  components: {
    PieChart,
    CountryTable,
    ProgressTable,
  },

  activated: function () {
    this.fetchSgmData();
    this.fetchBlankStats();
  },

  methods: {
    fetchSgmData() {
      this.loaded = false;
      axios.get(`${this.$basePrefix}participants/sgm_groups`, { params: {country: this.countryName } })
      .then(response => {
        this.sgmGroups = response.data;
        let groups = Object.keys(this.sgmGroups);
        let counts = [];
        groups.forEach((group) => {
          counts.push(this.sgmGroups[group]);
        });
        this.chartData = {
          labels: groups,
          datasets: [{
            borderWidth: 1,
            backgroundColor: [
            'rgba(87, 0, 228, 0.71)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(16, 44, 58, 0.36)',
            'rgba(40, 4, 246, 0.99)',
            'rgba(25, 255, 111, 0.47)',
            'rgba(246, 19, 4, 0.93)',
            'rgba(255, 0, 255, 0.51)',
            'rgba(200, 75, 0, 0.51)',
            'rgba(200, 224, 0, 1)',
            ],
            data: counts,
          }],
        };
        this.loaded = true;
      });
    },

    fetchBlankStats() {
      axios.get(`${this.$basePrefix}participants/blank_stats`, { params: { country: this.countryName } })
      .then(response => {
        this.blankStats = response.data;
      });
    }
  },
}
</script>

<style scoped>
h5 {
  font-size: 2em;
  text-align: center;
}
</style>
