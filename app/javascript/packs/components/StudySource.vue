<template>
  <div :key="'study-source'">
    <h5>Where participants heard about the SMILE Study</h5>
    <div class="card mb-5">
      <div v-if="loaded">
        <div class="row mb-4">
          <p>
            Eligible participants who completed the main block of the short
            survey or completed the original long survey in its entirety.
          </p>
          <PieChart :chartdata="chartData" :options="chartOptions"></PieChart>
        </div>
        <div class="row">
          <p>Sources for all participants</p>
          <div class="table-responsive">
            <table class="table table-hover">
              <thead>
                <tr>
                  <th>Source</th>
                  <th
                    onmouseover='this.style.textDecoration="underline"'
                    onmouseout='this.style.textDecoration="none"'
                    class="text-info"
                    title="Participants who completed the main block of the short survey or the long survey in its entirety and whose responses to the gender identity questions place them in one of the eligible sgm groups."
                  >
                    Eligible & Completed
                  </th>
                  <th
                    onmouseover='this.style.textDecoration="underline"'
                    onmouseout='this.style.textDecoration="none"'
                    class="text-info"
                    title="Participants whose responses to the sexual orientation questions place them in one of the eligible sgm groups although their gender identity responses disqualify them. Includes any participant who completed the SOGI section."
                  >
                    Derived
                  </th>
                  <th
                    onmouseover='this.style.textDecoration="underline"'
                    onmouseout='this.style.textDecoration="none"'
                    class="text-info"
                    title="Participants whose responses to the gender identity questions disqualify them from the eligible sgm groups. Includes any participant who completed the SOGI section."
                  >
                    Ineligible
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(value, key, index) in surveySources" :key="key">
                  <td>{{ namedSource(key) }}</td>
                  <td>{{ value['eligible'] }}</td>
                  <td>{{ value['derived'] }}</td>
                  <td>{{ value['ineligible'] }}</td>
                </tr>
                <tr>
                  <td><strong>Total</strong></td>
                  <td>
                    <strong>{{ eligibleTotal }}</strong>
                  </td>
                  <td>
                    <strong>{{ derivedTotal }}</strong>
                  </td>
                  <td>
                    <strong>{{ ineligibleTotal }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      <div v-else class="text-center">
        <b-spinner type="grow" variant="primary"></b-spinner>
      </div>
    </div>
    <div class="row">
      <SourcesTimeline :country-name="countryName" />
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import PieChart from './charts/PieChart';
import SourcesTimeline from './SourcesTimeline';

export default {
  name: 'StudySource',

  data: () => ({
    surveySources: {},
    loaded: false,
    chartOptions: {
      legend: {
        display: true,
      },
      responsive: true,
      maintainAspectRatio: false,
    },
    chartData: {},
    eligibleTotal: 0,
    ineligibleTotal: 0,
    derivedTotal: 0,
  }),

  props: {
    countryName: String,
  },

  components: {
    PieChart,
    SourcesTimeline,
  },

  watch: {
    countryName: function () {
      this.fetchData();
    },
  },

  mounted: function () {
    this.fetchData();
  },

  methods: {
    namedSource(number) {
      return this.$SOURCES[number];
    },
    fetchData() {
      this.loaded = false;
      axios
        .get(`${this.$basePrefix}participants/sources`, {
          params: { country: this.countryName },
        })
        .then((response) => {
          if (
            typeof response.data == 'string' &&
            response.data.startsWith('<!DOCTYPE html>')
          ) {
            window.location.reload();
          }
          this.surveySources = response.data;
          let sources = Object.keys(this.surveySources);
          let sourceNames = [];
          this.eligibleTotal = 0;
          this.ineligibleTotal = 0;
          this.derivedTotal = 0;
          sources.forEach((source) => {
            if (this.surveySources[source]['eligible'] > 0) {
              sourceNames.push(this.namedSource(source));
            }
            this.eligibleTotal += this.surveySources[source]['eligible'];
            this.ineligibleTotal += this.surveySources[source]['ineligible'];
            this.derivedTotal += this.surveySources[source]['derived'];
          });
          let counts = [];
          sources.forEach((source) => {
            let count = this.surveySources[source]['eligible'];
            if (count > 0) {
              counts.push(count);
            }
          });
          this.chartData = {
            labels: sourceNames,
            datasets: [
              {
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
                  'rgba(75, 60, 189, 0.8)',
                  'rgba(60, 160, 189, 0.8)',
                  'rgba(60, 189, 79, 0.69)',
                  'rgba(10, 82, 21, 0.6)',
                  'rgba(122, 138, 78, 0.86)',
                  'rgba(37, 6, 63, 0.52)',
                ],
                data: counts,
              },
            ],
          };
          this.loaded = true;
        });
    },
  },
};
</script>

<style scoped>
h5 {
  font-size: 2em;
  text-align: center;
}
p {
  font-size: 1.2em;
  font-weight: bold;
  text-align: center;
}
</style>
