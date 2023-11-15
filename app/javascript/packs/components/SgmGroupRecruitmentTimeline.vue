<template>
  <div class="card mb-5">
    <div class="card-header">
      <h5 class="card-title">SGM Recruitment Timeline</h5>
    </div>
    <div class="card-body">
      <div v-if="loaded" class="row">
        <LineChart
          v-if="loaded"
          :chartdata="chartData"
          :options="chartOptions"
        />
      </div>
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
  name: 'SgmGroupRecruitmentTimeline',

  props: {
    countryName: String,
  },

  components: {
    LineChart,
  },

  data() {
    return this.initialState();
  },

  created: function () {
    this.fetchData();
  },

  watch: {
    countryName: function () {
      this.reset();
      this.fetchData();
    },
  },

  methods: {
    initialState() {
      return {
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
      };
    },

    reset() {
      Object.assign(this.$data, this.initialState());
    },

    fetchData() {
      this.loaded = false;
      axios
        .get(`${this.$basePrefix}participants/sgm_timeline`, {
          params: { country: this.countryName },
        })
        .then((response) => {
          if (
            typeof response.data == 'string' &&
            response.data.includes('login-form')
          ) {
            window.location.reload();
          } else {
            this.loaded = true;
            this.chartData = this.getChartData(response.data);
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    getChartData(data) {
      let dates = [];
      Object.values(data)[0].forEach((weeklyStats) => {
        dates.push(Object.keys(weeklyStats)[0]);
      });
      let chartData = {
        labels: dates,
        datasets: [],
      };
      let colors = [
        '#e81416',
        '#79c314',
        '#a52a2a',
        '#487de7',
        '#ffa500',
        '#000000',
        '#70369d',
      ];
      let index = 0;
      let count = 0;
      Object.keys(data).forEach((sgmGroup) => {
        let weeklyStats = [];
        let cumulativeStats = [];
        let cumulative = 0;
        data[sgmGroup].forEach((stats) => {
          let value = Object.values(stats)[0];
          cumulative += value;
          weeklyStats.push(value);
          cumulativeStats.push(cumulative);
        });
        count = weeklyStats.length;
        let color = colors[index];
        chartData.datasets.push(
          {
            label: sgmGroup,
            backgroundColor: color,
            fill: false,
            borderWidth: 1,
            borderColor: color,
            data: weeklyStats,
          },
          {
            label: `${sgmGroup} (cumulative)`,
            backgroundColor: color,
            fill: false,
            borderWidth: 1,
            borderColor: color,
            borderDash: [5, 5],
            data: cumulativeStats,
          }
        );
        index++;
      });
      chartData.datasets.push({
        label: 'SGM Group Target',
        backgroundColor: '#008080',
        fill: false,
        borderWidth: 1,
        borderColor: '#008080',
        data: Array(count).fill(500),
      });
      return chartData;
    },
  },
};
</script>

<style scoped>
h5 {
  font-size: 2em;
  text-align: center;
}
</style>
