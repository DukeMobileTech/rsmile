<template>
  <div>
    <h5>Short Survey Block Progress</h5>
    <div v-if="loaded" class="row">
      <div class="table-responsive">
        <table class="table table-hover">
          <thead>
            <tr>
              <th>Survey Block</th>
              <th>Participant Count</th>
              <th>Block Progress</th> 
            </tr>
          </thead>
          <tbody>
            <tr v-for="(value, key, index) in surveys" :key="index">
              <td>{{key}}</td>
              <td>{{value}}</td>
              <td>{{((value / surveys['Started Short Survey']) * 100).toFixed(1)}} %</td> 
            </tr>
          </tbody>
        </table>
      </div>
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
