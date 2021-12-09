<template>
  <div id="app" class="container">
    <nav class="nav nav-pills nav-fill mt-2 mb-2">
      <li class="nav-item"><h1>{{ message }}</h1></li>
      <li class="nav-item">
        <a class="nav-link" :href="admin">Admin</a>
      </li>
    </nav>
    <Participant />
  </div>
</template>

<script>
 import Participant from './packs/components/Participant'

export default {
  data: function () {
    return {
      message: "SMILE Study",
      admin: `${this.$basePrefix}admin`
    }
  },

  components: {
    Participant
  }

}
</script>
