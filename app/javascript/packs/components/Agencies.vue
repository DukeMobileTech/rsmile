<template>
  <div>
    <div v-if="loaded">
      <b-table
        sticky-header="600px"
        responsive
        striped
        hover
        label-sort-asc=""
        label-sort-desc=""
        label-sort-clear=""
        :items="agencies"
        :fields="fields"
      >
      </b-table>
    </div>
    <div v-else class="text-center">
      <b-spinner type="grow" variant="primary"></b-spinner>
    </div>
  </div>
</template>
<script>
import axios from 'axios';
export default {
  name: 'Agencies',
  data() {
    return {
      loaded: false,
      agencies: [],
      fields: [],
    };
  },
  props: {
    countryName: String,
  },
  mounted: function () {
    this.fetchData();
  },
  methods: {
    fetchData: function () {
      axios
        .get(`${this.$basePrefix}survey_responses/agencies`, {
          params: {
            country: this.countryName,
          },
        })
        .then((response) => {
          this.agencies = response.data;
          this.fields = Object.keys(this.agencies[0]).map((key) => {
            return {
              key: key,
              label: key,
              sortable: true,
            };
          });
          this.loaded = true;
        })
        .catch((error) => {
          console.log(error);
        });
    },
  },
};
</script>
<style></style>
