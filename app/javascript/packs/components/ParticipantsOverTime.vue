<template>
    <div :key="'group-by-date'">
      <h5>Participant Recruitment Timeline</h5>
      <LineChart v-if="loaded" :chartdata="chartData" :options="chartOptions"></LineChart>
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
        axios.get(`${this.$basePrefix}participants/grouped`, { params: {country: this.countryName } })
        .then(response => {
          let grouped = response.data;
          let dates = [];
          let totalCounts = [];
          let total = [];
          grouped.forEach((item) => {
            dates.push(Object.keys(item)[0]);
            totalCounts.push(Object.values(item)[0][0]);
          });
          totalCounts.reduce((a, b, index) => total[index] = a + b, 0);
          this.chartData = {
            labels: dates,
            datasets: [{
              label: 'Weekly',
              fill: false,
              borderWidth: 1,
              borderColor: '#2554FF',
              backgroundColor: '#2554FF',
              data: totalCounts,
            },
            {
              label: 'Cumulative',
              fill: false,
              borderWidth: 1,
              borderColor: '#8e4ae8',
              backgroundColor: '#8e4ae8',
              data: total,
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
