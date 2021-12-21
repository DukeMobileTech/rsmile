<template>
  <div class="card mb-5">
    <div class="card-header">
      <h5 class="card-title">Participants Per Country</h5>
    </div>
    <div class="card-body">
      <BarChart :chartdata="chartData" :options="chartOptions"></BarChart>
    </div>
  </div>
</template>

<script>
import BarChart from './charts/BarChart'

export default {

  name: 'CountryChart',

  data: function () {
    const countries = Object.keys(this.participantsPerCountry);
    const participants = [];
    countries.forEach((country) => {
      participants.push(this.participantsPerCountry[country]['participants']);
    });

    return {
      chartData: {
        labels: countries,
        datasets: [{
          label: 'Number of participants',
          borderWidth: 1,
          backgroundColor: [
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)'
          ],
          borderColor: [
            'rgba(255,99,132,1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)'
          ],
          pointBorderColor: '#2554FF',
          data: participants
        }]
      },
      chartOptions: {
        legend: {
          display: false
        },
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero: true
            },
            gridLines: {
              display: true
            }
          }],
          xAxes: [{
            gridLines: {
              display: false
            }
          }]
        }
      }
    };
  },

  props: {
      participantsPerCountry: Object
  },

  components: {
    BarChart
  },

}

</script>

<style scoped>
h5 {
  font-size: 2em;
  text-align: center;
}
</style>
