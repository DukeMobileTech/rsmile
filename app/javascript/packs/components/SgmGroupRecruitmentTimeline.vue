<template>
  <div class="card mb-5">
    <div class="card-header">
      <h5 class="card-title">SGM Recruitment Timeline</h5>
    </div>
    <div class="card-body">
      <!-- <div v-if="loaded" class="row">
          <CountryTable
            :data-obj="baselines"
            :first-header="'Status'"
            :second-header="'Count'"
          />
        </div>
        <div v-else class="text-center">
          <b-spinner type="grow" variant="primary"></b-spinner>
        </div> -->
    </div>
  </div>
</template>

<script>
export default {
  name: 'SgmGroupRecruitmentTimeline',
  data() {
    return {
      loaded: false,
    };
  },
  methods: {
    fetchData() {
      this.loaded = false;
      // axios
      //   .get(`${this.$basePrefix}survey_responses/sgm_group_recruitment_timeline`, {
      //     params: { country: this.countryName },
      //   })
      //   .then((response) => {
      //     if (
      //       typeof response.data == 'string' &&
      //       response.data.includes('login-form')
      //     ) {
      //       window.location.reload();
      //     } else {
      //       this.sgmGroupRecruitmentTimeline = response.data;
      //       this.loaded = true;
      //     }
      //   })
      //   .catch((error) => {
      //     console.log(error);
      //   });
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
