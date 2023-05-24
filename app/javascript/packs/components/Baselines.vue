<template>
  <div class="card mt-5 mb-5">
    <div class="card-header">
      <h5 class="card-title">Baseline Surveys</h5>
    </div>
    <div class="card-body">
      <div v-if="loaded" class="row">
        <CountryTable :data-obj="surveyBaselines" :first-header="'Status'" :second-header="'Count'" />
      </div>
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

  activated: function () {
    this.fetchData();
  },

  methods: {
    fetchData() {
      this.loaded = false;
      axios.get(`${this.$basePrefix}survey_responses/baselines`, { params: {country: this.countryName } })
      .then(response => {
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
