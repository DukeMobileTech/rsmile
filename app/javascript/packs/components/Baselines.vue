<template>
  <div class="card mb-5">
    <div class="card-header">
      <h5 class="card-title">Baselines</h5>
    </div>
    <div class="card-body">
      <div v-if="loaded" class="row">
        <CountryTable
          :data-obj="baselines"
          :first-header="'Status'"
          :second-header="'Count'"
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
import CountryTable from './CountryTable';

export default {
  name: 'Baselines',

  props: {
    countryName: String,
  },

  data: () => ({
    baselines: {},
    loaded: false,
  }),

  components: {
    CountryTable,
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
    fetchData() {
      this.loaded = false;
      axios
        .get(`${this.$basePrefix}survey_responses/baselines`, {
          params: { country: this.countryName },
        })
        .then((response) => {
          if (
            typeof response.data == 'string' &&
            response.data.startsWith('<!DOCTYPE html>')
          ) {
            window.location.reload();
          }
          this.baselines = response.data;
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
</style>
