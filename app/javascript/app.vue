<template>
  <div id="app" class="container">
    <p>{{ message }}</p>
    <Participant />
  </div>
</template>

<script>
 import Participant from './packs/components/Participant'

export default {
  data: function () {
    return {
      message: "SMILE Study"
    }
  },

  components: {
    Participant
  }

}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
