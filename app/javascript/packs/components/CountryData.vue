<template>
  <div>
    <div>
      <button type="button" class="btn btn-outline-secondary" @click="goBack">Back</button>
    </div>
    <h5>{{countryName}}</h5>
    <StudySource :country-name="countryName"></StudySource>
    <SgmGroups :country-name="countryName"></SgmGroups>
    <ParticipantsOverTime :country-name="countryName"></ParticipantsOverTime>
  </div>
</template>

<script>
import axios from 'axios';
import PieChart from './charts/PieChart';
import CountryTable from './CountryTable';
import ParticipantsOverTime from './ParticipantsOverTime';
import StudySource from './StudySource';
import SgmGroups from './SgmGroups';

export default {
  name: 'CountryData',

  props: {
    countryName: String
  },

  components: {
    PieChart,
    CountryTable,
    ParticipantsOverTime,
    StudySource,
    SgmGroups,
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
