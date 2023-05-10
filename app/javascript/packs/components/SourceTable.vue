<template>
  <div :key="'source-table'">
    <button type="button" class="btn btn-link" @click="goBack">See Other Sources</button>
    <h6>{{this.$parent.namedSource(source)}}</h6>
    <div class="table-responsive">
      <table class="table table-hover">
        <thead>
          <tr>
            <th>Weekly Recruitment</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Weekly Counts</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
   name: 'SourceTable', 

   data: () => ({
      surveySources: {},
      loaded: false,
    }),

   props: {
        countryName: String,
        source: String,
        showSource: Boolean,
    },

  activated: function () {
    this.fetchSourceData();
  },

  methods: {
      fetchSourceData() {
        this.loaded = false;
        axios.get(`${this.$basePrefix}participants/source_timeline`, { params: {country: this.countryName, source: this.source } })
        .then(response => {
          // this.surveySources = response.data;
          // let surveyResponses = response.data;
          // console.log(surveyResponses);
          // let sources = Object.keys(surveyResponses);
          // let counts = [];
          // sources.forEach((source) => {
          //   counts.push(surveyResponses[source]);
          // });
          // this.loaded = true;
        });
      },
      goBack() {
        this.$parent.setShowSource(false);
      }
    },
}
</script>

<style scoped>
h6 {
  font-size: 1em;
  text-align: center;
}
</style>