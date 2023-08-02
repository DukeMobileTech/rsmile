<template>
  <div :key="'sgm-group'">
    <h5>SGM Groups</h5>
    <div class="row">
      <div class="col">
        <p>Eligible</p>
        <div v-if="loadingEligible" class="text-center">
          <b-spinner type="grow" variant="primary"></b-spinner>
        </div>
        <ProgressTable v-else :data-obj="sgmGroups" />
      </div>
      <div class="col">
        <div v-if="loadingEligible" class="text-center">
          <b-spinner type="grow" variant="primary"></b-spinner>
        </div>
        <PieChart v-else :chartdata="chartData" :options="chartOptions"></PieChart>
      </div>
    </div>
    <div class="row mt-3 border-top">
      <div class="col pt-1">
        <p>Ineligible</p>
        <div v-if="loadingIneligible" class="text-center">
          <b-spinner type="grow" variant="primary"></b-spinner>
        </div>
        <IneligibleTable v-else :data-obj="ineligibleSgmGroups" />
      </div>
      <div class="col pt-1">
        <p>Blanks</p>
        <div v-if="loadingBlank" class="text-center">
          <b-spinner type="grow" variant="primary"></b-spinner>
        </div>
        <CountryTable v-else :data-obj="blankStats" :first-header="'Survey Progress'" :second-header="'Count'" />
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import PieChart from './charts/PieChart';
import CountryTable from './CountryTable';
import ProgressTable from './ProgressTable';
import IneligibleTable from './IneligibleTable';

export default {
  name: 'SgmGroups',

  data: () => ({
    loadingEligible: false,
    loadingBlank: false,
    loadingIneligible: false,
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
    ineligibleSgmGroups: {},
  }),

  props: {
      countryName: String
  },

  components: {
    PieChart,
    CountryTable,
    ProgressTable,
    IneligibleTable,
  },

  watch: {
    countryName: function () {
      this.fetchData();
    }
  },

  mounted: function () {
    this.fetchData();
  },

  methods: {
    fetchData() {
      this.fetchEligibleSgmData();
      this.fetchIneligibleSgmData();
      this.fetchBlankStats();
    },

    fetchEligibleSgmData() {
      this.loadingEligible = true;
      axios.get(`${this.$basePrefix}participants/eligible_sgm_stats`, { params: {country: this.countryName } })
      .then(response => {
        if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
          window.location.reload();
        }
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
            'rgba(87, 0, 228, 0.6)',
            'rgba(40, 4, 246, 0.6)',
            'rgba(25, 255, 111, 0.5)',
            'rgba(246, 19, 4, 0.7)',
            'rgba(255, 0, 255, 0.5)',
            'rgba(200, 75, 0, 0.5)',
            'rgba(180, 164, 50, 0.7)',
            ],
            data: counts,
          }],
        };
        this.loadingEligible = false;
      });
    },

    fetchBlankStats() {
      this.loadingBlank = true;
      axios.get(`${this.$basePrefix}participants/blank_stats`, { params: { country: this.countryName } })
      .then(response => {
        if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
          window.location.reload();
        }
        this.blankStats = response.data;
        this.loadingBlank = false;
      });
    },

    fetchIneligibleSgmData() {
      this.loadingIneligible = true;
      axios.get(`${this.$basePrefix}participants/ineligible_sgm_stats`, { params: {country: this.countryName } })
      .then(response => {
        if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
          window.location.reload();
        }
        this.ineligibleSgmGroups = response.data;
        this.loadingIneligible = false;
      });
    },
  },
}
</script>

<style scoped>
h5 {
  font-size: 2em;
  text-align: center;
}
p {
  font-size: 1.2em;
  text-align: center;
  font-weight: bold;
}
</style>
