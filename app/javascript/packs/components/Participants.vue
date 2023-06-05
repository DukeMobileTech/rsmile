<template>
  <div class="card mb-5">
    <div class="card-header">
      <h5 class="card-title">SMILE Recruitment Timeline</h5>
    </div>
    <div class="card-body">
      <LineChart v-if="loaded" :chartdata="chartData" :options="chartOptions" />
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import LineChart from './charts/LineChart';

  export default {
    name: 'Participants',

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
      colors: {
        'Kenya': '#006600',
        'Kenya (cumulative)': '#000000',
        'Vietnam': '#DA251D',
        'Vietnam (cumulative)': '#FFCD00',
        'Brazil': '#0C87D1',
        'Brazil (cumulative)': '#002776',
        'All': '#732982',
      }
    }),

    components: {
      LineChart,
    },

    mounted: function () {
      this.fetchData();
    },

    methods: {
      fetchData() {
        this.loaded = false;
        axios.get(`${this.$basePrefix}participants/weekly_participants`)
        .then(response => {
          if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
            window.location.reload();
          }
          let datasets = [];
          let countries = Object.keys(response.data);
          let dates = [];
          Object.values(response.data)[0].forEach((weeklyStats) => {
            dates.push(Object.keys(weeklyStats)[0]);
          });
          let allWeeklyCounts = {};
          countries.forEach((country) => {
            let weeklyCounts = [];
            let cumulativeCounts = [];
            let total = 0;
            response.data[country].forEach((countryData) => {
              let count = Object.values(countryData)[0];
              total += count;
              weeklyCounts.push(count);
              cumulativeCounts.push(total);
              let date = Object.keys(countryData)[0];
              if (allWeeklyCounts[date]) {
                allWeeklyCounts[date] += count;
              } else {
                allWeeklyCounts[date] = count;
              }
            });
            let color = this.colors[country];
            datasets.push({
              label: country,
              fill: false,
              borderWidth: 1,
              borderColor: color,
              backgroundColor: color,
              data: weeklyCounts,
            });
            let cumulativeColor = this.colors[country + " (cumulative)"];
            datasets.push({
              label: country + " (cumulative)",
              fill: false,
              borderWidth: 1,
              borderColor: cumulativeColor,
              backgroundColor: cumulativeColor,
              data: cumulativeCounts,
            });
          });
          let allCumulativeCounts = [];
          let cumulativeTotal = 0;
          Object.values(response.data)[0].forEach((weeklyStats) => {
            let week = Object.keys(weeklyStats)[0];
            cumulativeTotal += allWeeklyCounts[week];
            allCumulativeCounts.push(cumulativeTotal);
          });
          let allColor = this.colors['All'];
            datasets.push({
              label: 'SMILE (cumulative)',
              fill: false,
              borderWidth: 1,
              borderColor: allColor,
              backgroundColor: allColor,
              data: allCumulativeCounts,
            });
          this.chartData = {
            labels: dates,
            datasets: datasets,
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
