<template>
  <div>
    <h5>Short Survey Block Progress</h5>
    <div v-if="loaded" class="row">
      <div class="col-sm-6">
        <div class="table-responsive">
          <table class="table table-hover">
            <thead>
              <tr>
                <th>Block</th>
                <th>Participants</th>
                <th>Progress</th>
                <th>Eligible</th>
                <th>Progress</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(value, key, index) in surveys" :key="index">
                <td>{{key}}</td>
                <td>{{value[0]}}</td>
                <td>{{((value[0] / surveys['Started Short Survey'][0]) * 100).toFixed(1)}} %</td>
                <td>{{value[1]}}</td>
                <td>{{((value[1] / surveys['Started Short Survey'][0]) * 100).toFixed(1)}} %</td>
              </tr>
            </tbody>
          </table>
        </div>
        <p><strong>Caveats</strong></p>
        <ul>
          <li>Participants/Eligible columns are based on the number of participants who have started the short baseline survey (original long survey participants are not included).</li>
          <li>Progress is based on the number of participants who have completed that block versus those who started the survey.</li>
          <li>Participants column includes both eligible and ineligible participants.</li>
          <li>Duplicate surveys are excluded.</li>
        </ul>
      </div>
      <div class="col-sm-6">
        <BarChart :chartdata="chartData" :options="chartOptions"></BarChart>
      </div>
    </div>
    <div v-else class="text-center">
      <b-spinner type="grow" variant="primary"></b-spinner>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import BarChart from './charts/BarChart.vue';

export default {
  name: 'Progress',

  props: {
    countryName: String,
  },

  data: () => ({
    surveys: {},
    loaded: false,
    chartData: {},
    chartOptions: {
      scales: {
        yAxes: [{
          ticks: {
            beginAtZero: true
          },
          gridLines: {
            display: true
          }
        }],
        xAxes: [ {
          gridLines: {
            display: true
          }
        }]
      },
      legend: {
        display: true
      },
      responsive: true,
      maintainAspectRatio: false
    },
  }),

  components: {
    BarChart,
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
      this.loaded = false;
      axios.get(`${this.$basePrefix}survey_responses/progress`, { params: {country: this.countryName } })
      .then(response => {
        if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
          window.location.reload();
        }
        this.surveys = response.data;
        this.chartData = {
          labels: ['Started Short Survey', 'Completed SOGI Block', 'Completed Main Block', 'Completed Group A', 'Completed Group B', 'Completed Group C', 'Completed 1 Group', 'Completed 2 Groups', 'Completed 3 Groups'],
          datasets: [
            { label: 'All Participants',
              backgroundColor: 'rgba(246, 19, 4, 0.7)',
              data: [this.surveys['Started Short Survey'][0], this.surveys['Completed SOGI Block'][0], this.surveys['Completed Main Block'][0], this.surveys['Completed Group A'][0], this.surveys['Completed Group B'][0], this.surveys['Completed Group C'][0], this.surveys['Completed 1 Group'][0], this.surveys['Completed 2 Groups'][0], this.surveys['Completed 3 Groups'][0]],
            },
            { label: 'Eligible Participants',
              backgroundColor: 'rgba(87, 0, 228, 0.6)',
              data: [this.surveys['Started Short Survey'][1], this.surveys['Completed SOGI Block'][1], this.surveys['Completed Main Block'][1], this.surveys['Completed Group A'][1], this.surveys['Completed Group B'][1], this.surveys['Completed Group C'][1], this.surveys['Completed 1 Group'][1], this.surveys['Completed 2 Groups'][1], this.surveys['Completed 3 Groups'][1]],
            }
          ],
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
