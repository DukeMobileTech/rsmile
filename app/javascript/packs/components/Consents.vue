<template>
  <div class="card mb-5">
    <div class="card-header">
      <h5 class="card-title">Consents</h5>
    </div>
    <div class="card-body">
      <div class="row">
        <div class="col">
          <CountryTable :data-obj="surveyConsents" :first-header="'Status'" :second-header="'Count'" />
        </div>
        <div class="col">
          <PieChart v-if="loaded" :chartdata="chartData" :options="chartOptions"></PieChart>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import PieChart from './charts/PieChart';
import CountryTable from './CountryTable';

export default {
  name: 'Consents',

  props: {
    countryName: String,
  },

  data: () => ({
    surveyConsents: {},
    loaded: false,
    chartOptions: {
        legend: {
          display: true
        },
        responsive: true,
        maintainAspectRatio: false
      },
    chartData: {},
  }),

  components: {
    PieChart,
    CountryTable,
  },

  activated: function () {
    this.fetchData();
  },

  methods: {
    fetchData() {
      this.loaded = false;
      axios.get(`${this.$basePrefix}survey_responses/consents`, { params: {country: this.countryName } })
      .then(response => {
        this.surveyConsents = response.data;
        let consents = Object.keys(this.surveyConsents);
        let counts = [];
        consents.forEach((type) => {
          counts.push(this.surveyConsents[type]);
        });
        this.chartData = {
          labels: consents,
          datasets: [{
            borderWidth: 1,
            backgroundColor: [
              'rgba(200, 224, 0, 1)',
              'rgba(87, 0, 228, 0.71)',
            ],
            data: counts,
          }],
        };
        this.loaded = true;
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
</style>
