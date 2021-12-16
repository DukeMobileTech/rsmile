<template>
  <div id="app" class="container">
    <nav class="navbar navbar-light bg-light mt-2 mb-2">
        <div class="container-fluid">
        <div class="nav-item"><h1>{{ message }}</h1></div>
        <div class="nav-item">
          <button v-on:click="handleLogout" class="btn btn-danger" >Sign Out</button>
        </div>
      </div>
    </nav>
    <keep-alive>
        <component @countryname="updateCountry" :is="visibleComponent" v-bind="currentProperties"></component>
    </keep-alive>
  </div>
</template>

<script>
 import axios from 'axios';
 import Participant from './packs/components/Participant';
 import CountryData from './packs/components/CountryData';

export default {
  data: function () {
    return {
      message: "SMILE Study",
      admin: `${this.$basePrefix}admin`,
      country: null,
    }
  },

  components: {
    Participant,
    CountryData,
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
    },
    updateCountry(value) {
      this.country = value;
    }
  },

  computed: {
    visibleComponent() {
      if(this.country == null) {
        return 'Participant';
      } else {
        return 'CountryData';
      }
    },
    currentProperties() {
      if (this.visibleComponent === 'CountryData') {
        return { countryName: this.country }
      }
    }
  }

}
</script>
