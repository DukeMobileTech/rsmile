<template>
  <div>
    <h5>Short Survey Block Progress</h5>
    <div v-if="loaded" class="row">
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
      </ul>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import CountryTable from './CountryTable';

export default {
  name: 'Progress',

  props: {
    countryName: String,
  },

  data: () => ({
    surveys: {},
    loaded: false,
  }),

  components: {
    CountryTable,
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
