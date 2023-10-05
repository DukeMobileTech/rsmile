<template>
  <div class="card mb-5">
    <div class="card-header">
      <h6 class="card-title">Recruitment Timeline</h6>
    </div>
    <div class="card-body">
      <LineChart v-if="loaded" :chartdata="chartData" :options="chartOptions" />
      <div v-else class="text-center">
        <b-spinner type="grow" variant="primary"></b-spinner>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import LineChart from './charts/LineChart';

export default {
  name: 'Timeline',

  data: () => ({
    loaded: false,
    chartOptions: {
      scales: {
        yAxes: [
          {
            ticks: {
              beginAtZero: true,
            },
            gridLines: {
              display: true,
            },
          },
        ],
        xAxes: [
          {
            gridLines: {
              display: false,
            },
          },
        ],
      },
      legend: {
        display: true,
      },
      responsive: true,
      maintainAspectRatio: false,
    },
    chartData: {},
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
      axios
        .get(`${this.$basePrefix}participants/weekly_participants`)
        .then((response) => {
          if (
            typeof response.data == 'string' &&
            response.data.startsWith('<!DOCTYPE html>')
          ) {
            window.location.reload();
          }
          let countries = Object.keys(response.data);
          let allWeeklyCounts = {};
          let datasets = this.getDatasets(countries, response, allWeeklyCounts);
          let dates = this.getDates(response);
          let allCumulativeCounts = this.getCumulativeTotals(
            response,
            allWeeklyCounts
          );
          let allColor = this.$COLORS['All'];
          let targetColor = this.$COLORS['Target'];
          datasets.push({
            label: 'SMILE (cumulative)',
            fill: false,
            borderWidth: 1,
            borderColor: allColor,
            backgroundColor: allColor,
            data: allCumulativeCounts,
          });
          datasets.push({
            label: 'Study Target',
            fill: false,
            borderWidth: 1,
            borderColor: targetColor,
            backgroundColor: targetColor,
            data: allCumulativeCounts.map((count) => 10000),
          });
          this.chartData = {
            labels: dates,
            datasets: datasets,
          };
          this.loaded = true;
        });
    },
    getDates(response) {
      let dates = [];
      Object.values(response.data)[0].forEach((weeklyStats) => {
        dates.push(Object.keys(weeklyStats)[0]);
      });
      return dates;
    },
    getDatasets(countries, response, allWeeklyCounts) {
      let datasets = [];
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
        let color = this.$COLORS[country];
        datasets.push({
          label: country,
          fill: false,
          borderWidth: 1,
          borderColor: color,
          backgroundColor: color,
          data: weeklyCounts,
        });
        let cumulativeColor = this.$COLORS[country + ' (cumulative)'];
        datasets.push({
          label: country + ' (cumulative)',
          fill: false,
          borderWidth: 1,
          borderColor: cumulativeColor,
          backgroundColor: cumulativeColor,
          data: cumulativeCounts,
        });
      });
      return datasets;
    },
    getCumulativeTotals(response, allWeeklyCounts) {
      let allCumulativeCounts = [];
      let cumulativeTotal = 0;
      Object.values(response.data)[0].forEach((weeklyStats) => {
        let week = Object.keys(weeklyStats)[0];
        cumulativeTotal += allWeeklyCounts[week];
        allCumulativeCounts.push(cumulativeTotal);
      });
      return allCumulativeCounts;
    },
  },
};
</script>

<style scoped>
h6 {
  font-size: 1.5em;
  text-align: center;
}
</style>
