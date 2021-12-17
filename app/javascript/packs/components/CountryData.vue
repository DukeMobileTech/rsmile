<template>
  <div>
    <div>
      <button type="button" class="btn btn-outline-secondary" @click="goBack">Back</button>
    </div>
    <h5>{{countryName}}</h5>
    <div :key="'study-source'" class="card mt-5">
      <div class="card-header">
        <h5 class="card-title">How did you hear about this study?</h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col">
            <CountryTable :data-obj="surveySources" :first-header="'Source'" :second-header="'Count'" />
          </div>
          <div class="col">
            <PieChart v-if="loaded" :chartdata="sourceChartData" :options="chartOptions"></PieChart>
          </div>
        </div>
      </div>
    </div>
    <div :key="'sgm-group'" class="card mt-5">
      <div class="card-header">
        <h5 class="card-title">SGM Groups</h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col">
            <CountryTable :data-obj="sgmGroups" :first-header="'SGM Group'" :second-header="'Count'" />
          </div>
          <div class="col">
            <PieChart v-if="sgmLoaded" :chartdata="sgmChartData" :options="chartOptions"></PieChart>
          </div>
        </div>
      </div>
    </div>
    <ParticipantsOverTime :country-name="countryName"></ParticipantsOverTime>
  </div>
</template>

<script>
import axios from 'axios';
import PieChart from './PieChart';
import CountryTable from './CountryTable';
import ParticipantsOverTime from './ParticipantsOverTime';

  export default {
    name: 'CountryData',

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
      sourceChartData: {},
      sgmLoaded: false,
      sgmGroups: {},
      sgmChartData: {},
    }),

    props: {
        countryName: String
    },

    components: {
      PieChart,
      CountryTable,
      ParticipantsOverTime,
    },

    activated: function () {
      this.fetchSourceData();
      this.fetchSgmData();
    },

    methods: {
      goBack() {
        this.$emit("countryname", null);
      },
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
          this.sourceChartData = {
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
              ],
              data: counts,
            }],
          };
          this.loaded = true;
        });
      },
      fetchSgmData() {
        this.sgmLoaded = false;
        axios.get(`${this.$basePrefix}participants/sgm_groups`, { params: {country: this.countryName } })
        .then(response => {
          this.sgmGroups = response.data;
          let groups = Object.keys(this.sgmGroups);
          let counts = [];
          groups.forEach((group) => {
            counts.push(this.sgmGroups[group]);
          });
          this.sgmChartData = {
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
          this.sgmLoaded = true;
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
