<template>
  <div>
    <h5>Baseline Surveys</h5>
    <div v-if="loaded" class="row">
      <CountryTable :data-obj="surveyBaselines" :first-header="'Status'" :second-header="'Count'" />
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import CountryTable from './CountryTable';

export default {
  name: 'Baselines',

  props: {
    countryName: String,
  },

  data: () => ({
    surveyBaselines: {},
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
      axios.get(`${this.$basePrefix}survey_responses/baselines`, { params: {country: this.countryName } })
      .then(response => {
        if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
          window.location.reload();
        }
        this.surveyBaselines = response.data;
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
