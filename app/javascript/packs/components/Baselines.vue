<template>
  <div class="card mt-5 mb-5">
    <div class="card-header">
      <h5 class="card-title">Baseline Surveys</h5>
    </div>
    <div class="card-body">
      <div class="row">
        <div class="col">
          <CountryTable :data-obj="surveyBaselines" :first-header="'Status'" :second-header="'Count'" />
          <div>**Duplicates excluded in Completed but not in Partials**</div>
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
  name: 'Baselines',

  props: {
    countryName: String,
  },

  data: () => ({
    surveyBaselines: {},
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
      axios.get(`${this.$basePrefix}survey_responses/baselines`, { params: {country: this.countryName } })
      .then(response => {
        this.surveyBaselines = response.data;
        let consents = Object.keys(this.surveyBaselines);
        let counts = [];
        consents.forEach((type) => {
          counts.push(this.surveyBaselines[type]);
        });
        this.chartData = {
          labels: consents,
          datasets: [{
            borderWidth: 1,
            backgroundColor: [
              'rgba(200, 224, 0, 1)',
              'rgba(40, 4, 246, 0.99)',
              'rgba(246, 19, 4, 0.93)',
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
