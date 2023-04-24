<template>
  <div>
    <div>
      <button type="button" class="btn btn-outline-secondary" @click="goBack">Back</button>
    </div>
    <h5>{{countryName}}</h5>
    <StudySource :country-name="countryName"></StudySource>
    <SgmGroups :country-name="countryName"></SgmGroups>
    <Baselines :country-name="countryName"></Baselines>
    <ParticipantsOverTime :country-name="countryName"></ParticipantsOverTime>
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
