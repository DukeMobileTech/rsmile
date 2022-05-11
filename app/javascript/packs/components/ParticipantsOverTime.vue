<template>
    <div :key="'group-by-date'" class="card mt-5 mb-5">
      <div class="card-header">
        <h5 class="card-title">Recruitment Timeline</h5>
      </div>
      <div class="card-body">
        <LineChart v-if="loaded" :chartdata="chartData" :options="chartOptions"></LineChart>
      </div>
    </div>
</template>

<script>
import axios from 'axios';
import LineChart from './charts/LineChart';

  export default {
    name: 'ParticipantsOverTime',

    data: () => ({
      loaded: false,
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
              display: false
            }
          }]
        },
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
      LineChart,
    },

    activated: function () {
      this.fetchData();
    },

    methods: {
      fetchData() {
        this.loaded = false;
        axios.get(`${this.$basePrefix}participants/grouped`, { params: {country: this.countryName } })
        .then(response => {
          let grouped = response.data;
          let dates = [];
          let totalCounts = [];
          let total = [];
          let eligibleCounts = [];
          let eligible = [];
          grouped.forEach((item) => {
            dates.push(Object.keys(item)[0]);
            totalCounts.push(Object.values(item)[0][0]);
            eligibleCounts.push(Object.values(item)[0][1]);
          });
          totalCounts.reduce((a, b, index) => total[index] = a + b, 0);
          eligibleCounts.reduce((a, b, index) => eligible[index] = a + b, 0);
          this.chartData = {
            labels: dates,
            datasets: [{
              label: 'Weekly Participants',
              fill: false,
              borderWidth: 1,
              borderColor: '#2554FF',
              backgroundColor: '#2554FF',
              data: totalCounts,
            },
            {
              label: 'Total Cumulative Participants',
              fill: false,
              borderWidth: 1,
              borderColor: '#8e4ae8',
              backgroundColor: '#8e4ae8',
              data: total,
            },
            {
              label: 'Eligible Cumulative Participants',
              fill: false,
              borderWidth: 1,
              borderColor: '#94C973',
              backgroundColor: '#94C973',
              data: eligible,
            },
          ]};
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
