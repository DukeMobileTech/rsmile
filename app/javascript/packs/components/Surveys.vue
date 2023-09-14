<template>
  <div>
    <Baselines :country-name="countryName"></Baselines>
    <Consents :country-name="countryName"></Consents>
  </div>
</template>

<script>
import Baselines from './Baselines.vue';
import Consents from './Consents.vue';

export default {
  name: 'Surveys',

  props: {
    countryName: String,
  },

  components: {
    Baselines,
    Consents,
  },
};
</script>
