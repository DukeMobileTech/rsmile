<template>
  <div>
    <h3>SMILE Study</h3>
    <Participants />
    <Timeline />
  </div>
</template>

<script>
import Timeline from './Timeline';
import Participants from './Participants';

export default {
  name: 'Home',

  components: {
    Timeline,
    Participants,
  },
};
</script>

<style scoped>
h3 {
  font-size: 2em;
  text-align: center;
}
</style>
