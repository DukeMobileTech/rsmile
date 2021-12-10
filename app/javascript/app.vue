<template>
  <div id="app" class="container">
    <nav class="nav nav-pills nav-fill mt-2 mb-2">
      <li class="nav-item"><h1>{{ message }}</h1></li>
      <!-- <li class="nav-item">
        <a class="nav-link" :href="admin">Admin</a>
      </li> -->
      <li class="nav-item">
        <button v-on:click="handleLogout" class="btn btn-danger" >Sign Out</button>
      </li>
    </nav>
    <Participant />
  </div>
</template>

<script>
 import axios from 'axios';
 import Participant from './packs/components/Participant'

export default {
  data: function () {
    return {
      message: "SMILE Study",
      admin: `${this.$basePrefix}admin`,
    }
  },

  components: {
    Participant
  },

  methods: {
    handleLogout () {
      axios.defaults.headers.common['X-CSRF-TOKEN'] = document.head.querySelector('meta[name="csrf-token"]').content;
      axios.delete(`${this.$basePrefix}sign_out`)
      .then(response => {
        window.location.reload();
      }).catch(error => {
        window.location.reload();
      });
    }
  }

}
</script>
