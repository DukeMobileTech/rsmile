<template>
<div>
   <div class="card">
     <div class="card-header">
       <h3 class="card-title">
         Summary Statistics
       </h3>
     </div>

     <table class="table card-table">
       <thead>
         <tr>
           <th>Country</th>
           <th>Number of Participants</th>
         </tr>
       </thead>

       <tbody>
         <tr v-for="(participantCount, country, index) in participantsPerCountry" :key="country">
           <td>{{country}}</td>
           <td>{{participantCount}}</td>
         </tr>
       </tbody>
     </table>

   </div>

   <CountryChart v-if="loaded" :participants-per-country="participantsPerCountry"/>
</div>

</template>

<script>
 import axios from 'axios';

 import CountryChart from './CountryChart'

 export default {
   name: 'Participant',

   data: () => ({
     participantsPerCountry: {},
     loaded: false,
   }),

   components: {
     CountryChart
   },

   created: function () {
     this.fetchParticipants();
   },

   methods: {
     fetchParticipants () {
       this.loaded = false;
       axios.get('/participants').then(response => {
         this.participantsPerCountry = response.data;
         this.loaded = true;
       });
     }
   }
 };
</script>

<style scoped>
h3 {
  font-size: 2em;
  text-align: center;
}
</style>
