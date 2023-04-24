<template>
  <div :key="'study-source'" class="card mt-2">
    <div class="card-header">
      <h5 class="card-title">How did you hear about this study?</h5>
    </div>
    <div class="card-body">
      <div class="row">
        <div class="col">
          <CountryTable :data-obj="surveySources" :first-header="'Source'" :second-header="'Count'" />
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
    name: 'StudySource',

    data: () => ({
      surveySources: {},
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

    props: {
        countryName: String
    },

    components: {
      PieChart,
      CountryTable,
    },

    activated: function () {
      this.fetchSourceData();
    },

    methods: {
      fetchSourceData() {
        this.loaded = false;
        axios.get(`${this.$basePrefix}survey_responses/sources`, { params: {country: this.countryName } })
        .then(response => {
          this.surveySources = response.data;
          let surveyResponses = response.data;
          let sources = Object.keys(surveyResponses);
          let counts = [];
          sources.forEach((source) => {
            counts.push(surveyResponses[source]);
          });
          this.chartData = {
            labels: sources,
            datasets: [{
              borderWidth: 1,
              backgroundColor: [
              'rgba(255, 99, 132, 0.2)',
              'rgba(54, 162, 235, 0.2)',
              'rgba(87, 0, 228, 0.71)',
              'rgba(255, 53, 53, 0.83)',
              'rgba(16, 44, 58, 0.36)',
              'rgba(40, 4, 246, 0.99)',
              'rgba(25, 255, 111, 0.47)',
              'rgba(246, 19, 4, 0.93)',
              'rgba(255, 0, 255, 0.51)',
              'rgba(200, 75, 0, 0.51)',
              'rgba(200, 224, 0, 1)',
              'rgba(143, 89, 160, 0.55)',
              'rgba(143, 105, 22, 0.5)',
              'rgba(40, 120, 84, 0.6)',
              'rgba(77, 191, 25, 0.7)',
              'rgba(127, 52, 187, 0.7)',
              'rgba(12, 80, 220, 0.4)',
              'rgba(255, 169, 184, 0.85)',
              'rgba(140, 125, 255, 0.8)',
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
