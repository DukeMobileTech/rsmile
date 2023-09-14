<template>
  <div class="card mb-5">
    <div class="card-header">
      <h5 class="card-title">Consents</h5>
    </div>
    <div class="card-body">
      <div v-if="loaded" class="row">
        <CountryTable
          :data-obj="consents"
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
  name: 'Consents',
  props: {
    countryName: String,
  },
  components: {
    CountryTable,
  },
  data: () => ({
    consents: {},
    loaded: false,
  }),
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
        .get(`${this.$basePrefix}survey_responses/consents`, {
          params: { country: this.countryName },
        })
        .then((response) => {
          if (
            typeof response.data == 'string' &&
            response.data.startsWith('<!DOCTYPE html>')
          ) {
            window.location.reload();
          }
          this.consents = response.data;
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
