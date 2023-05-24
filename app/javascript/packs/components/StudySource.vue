<template>
  <div :key="'study-source'" class="card mt-2">
    <div class="card-header">
      <h5 class="card-title">How did you hear about this study?</h5>
    </div>
    <div v-if="loaded" class="card-body">
      <div class="row mb-4">
        <p>Eligible participants chart</p>
        <PieChart :chartdata="chartData" :options="chartOptions"></PieChart>
      </div>
      <div class="row">
        <p>All participants table</p>
        <div class="table-responsive">
          <table class="table table-hover">
            <thead>
              <tr>
                <th>Source</th>
                <th onmouseover='this.style.textDecoration="underline"'
                    onmouseout='this.style.textDecoration="none"'
                    class="text-info"
                    title="Participants whose responses to the orientation questions place them in one of the eligible sgm groups.">
                    Eligible
                </th>
                <th onmouseover='this.style.textDecoration="underline"'
                    onmouseout='this.style.textDecoration="none"'
                    class="text-info"
                    title="Participants whose responses to the attraction questions place them in one of the eligible sgm groups although their orientation responses disqualify them.">
                    Derived
                </th>
                <th onmouseover='this.style.textDecoration="underline"'
                    onmouseout='this.style.textDecoration="none"'
                    class="text-info"
                    title="Participants whose responses to the orientation questions disqualify them from the eligible sgm groups. Includes duplicates and partials.">
                    Ineligible
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(value, key, index) in surveySources" :key="key">
                <td>{{namedSource(key)}}</td>
                <td>{{value['eligible']}}</td>
                <td>{{value['derived']}}</td>
                <td>{{value['ineligible']}}</td>
              </tr>
              <tr>
                <td><strong>Total</strong></td>
                <td><strong>{{eligibleTotal}}</strong></td>
                <td><strong>{{derivedTotal}}</strong></td>
                <td><strong>{{ineligibleTotal}}</strong></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="row">
        <SourcesTimeline :country-name="countryName" />
      </div>
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
            display: true
          },
          responsive: true,
          maintainAspectRatio: false
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

    activated: function () {
      this.fetchSourceData();
    },

    methods: {
      namedSource(number) {
        let name = '';
        switch (number) {
          case '0':
            name = 'Not Indicated'; break;
          case '1':
            name = 'Radio advertisement'; break;
          case '2':
            name = 'TV advertisement'; break;
          case '3':
            name = 'Podcast'; break;
          case '4':
            name = 'Billboard / sign / poster / pamphlet / newspaper advertisement'; break;
          case '5':
            name = 'Newspaper article / magazine article / newsletter'; break;
          case '6':
            name = 'Social media advertisement'; break;
          case '7':
            name = 'Social media post / discussion'; break;
          case '8':
            name = 'Friend / family member / acquaintance'; break;
          case '9':
            name = 'Local organization'; break;
          case '10':
            name = 'Local organization / peer educator'; break;
          case '11':
            name = 'Other'; break;
          case '12':
            name = 'VTC Team CBO'; break;
          case '13':
            name = 'FTM Vietnam Organization'; break;
          case '14':
            name = 'CSAGA'; break;
          case '15':
            name = 'BE+ Clun in University of Social Sciences and Humanities (HCMUSSH)'; break;
          case '16':
            name = 'Event Club in Van Lang University'; break;
          case '17':
            name = 'Club in Can Tho University'; break;
          case '18':
            name = 'RMIT University Vietnam'; break;
          case '19':
            name = 'YKAP Vietnam'; break;
          case '20':
            name = 'Song Tre Son La'; break;
          case '21':
            name = 'The Leader House An Giang'; break;
          case '22':
            name = 'Vuot Music Video'; break;
          case '23':
            name = 'Motive Agency'; break;
          case '24':
            name = 'Social work Club from University of Labour and Social Affairs 2'; break;
          default:
            name = number;
        }
        return name;
      },
      fetchSourceData() {
        this.loaded = false;
        axios.get(`${this.$basePrefix}survey_responses/sources`, { params: {country: this.countryName } })
        .then(response => {
          this.surveySources = response.data;
          let sources = Object.keys(this.surveySources);
          let sourceNames = [];
          this.eligibleTotal = 0;
          this.ineligibleTotal = 0;
          this.derivedTotal = 0;
          sources.forEach((source) => {
            sourceNames.push(this.namedSource(source));
            this.eligibleTotal += this.surveySources[source]['eligible'];
            this.ineligibleTotal += this.surveySources[source]['ineligible'];
            this.derivedTotal += this.surveySources[source]['derived'];
          });
          let counts = [];
          sources.forEach((source) => {
            let count = this.surveySources[source]['eligible'];
            counts.push(count);
          });
          this.chartData = {
            labels: sourceNames,
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
              'rgba(75, 60, 189, 0.8)',
              'rgba(60, 160, 189, 0.8)',
              'rgba(60, 189, 79, 0.69)',
              'rgba(10, 82, 21, 0.6)',
              'rgba(122, 138, 78, 0.86)',
              'rgba(37, 6, 63, 0.52)',
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
p {
  font-size: 1.2em;
  font-weight: bold;
  text-align: center;
}
</style>
