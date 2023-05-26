<template>
  <div>
    <div>
      <button type="button" class="btn btn-outline-secondary" @click="goBack">Back</button>
    </div>
    <h5>{{countryName}}</h5>
    <b-card no-body>
      <b-tabs card justified content-class="mt-3 mb-5">
        <b-tab lazy title="Recruitment Sources">
          <StudySource :country-name="countryName"></StudySource>
        </b-tab>
        <b-tab lazy title="SGM Groups">
          <SgmGroups :country-name="countryName"></SgmGroups>
        </b-tab>
        <b-tab lazy title="Recruitment Timeline">
          <ParticipantsOverTime :country-name="countryName"></ParticipantsOverTime>
        </b-tab>
        <b-tab lazy title="Baseline Surveys">
          <Baselines :country-name="countryName"></Baselines>
        </b-tab>
      </b-tabs>
    </b-card>
  </div>
</template>

<script>
import ParticipantsOverTime from './ParticipantsOverTime';
import StudySource from './StudySource';
import SgmGroups from './SgmGroups';
import Baselines from './Baselines';

export default {
  name: 'CountryData',

  props: {
    countryName: String
  },

  components: {
    ParticipantsOverTime,
    StudySource,
    SgmGroups,
    Baselines,
  },

  methods: {
    goBack() {
      this.$emit("countryname", null);
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
