<template>
  <div>
    <div>
      <button type="button" class="btn btn-outline-secondary" @click="goBack">
        Back
      </button>
    </div>
    <h5>{{ countryName }}</h5>
    <b-card no-body class="mb-5">
      <b-tabs card justified content-class="mt-3 mb-5">
        <b-tab lazy title="SGM Groups">
          <SgmGroups :country-name="countryName"></SgmGroups>
        </b-tab>
        <b-tab lazy title="Recruitment Sources">
          <StudySource :country-name="countryName"></StudySource>
        </b-tab>
        <b-tab lazy title="Recruitment Timeline">
          <CountryTimeline :country-name="countryName"></CountryTimeline>
        </b-tab>
        <b-tab lazy title="Surveys">
          <Surveys :country-name="countryName"></Surveys>
        </b-tab>
        <b-tab lazy title="Baseline Blocks Progress">
          <Progress :country-name="countryName"></Progress>
        </b-tab>
        <b-tab v-if="countryName == 'Kenya'" lazy title="Mobilizer Recruitment">
          <Mobilizers :country-name="countryName"></Mobilizers>
        </b-tab>
        <b-tab v-if="countryName == 'Vietnam'" lazy title="Agency Recruitment">
          <Agencies :country-name="countryName"></Agencies>
        </b-tab>
      </b-tabs>
    </b-card>
  </div>
</template>

<script>
import CountryTimeline from './CountryTimeline';
import StudySource from './StudySource';
import SgmGroups from './SgmGroups';
import Progress from './Progress';
import Mobilizers from './Mobilizers';
import Agencies from './Agencies';
import Surveys from './Surveys.vue';

export default {
  name: 'CountryData',

  props: {
    countryName: String,
  },

  components: {
    CountryTimeline,
    StudySource,
    SgmGroups,
    Progress,
    Mobilizers,
    Agencies,
    Surveys,
  },

  methods: {
    goBack() {
      this.$emit('countryname', null);
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
