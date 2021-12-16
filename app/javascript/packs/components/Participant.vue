<template>
<div>
   <div class="card mb-5">
     <div class="card-header">
       <h3 class="card-title">
         Summary Statistics
       </h3>
     </div>

     <div class="table-responsive">
       <table class="table card-table table-hover">
         <thead>
           <tr>
             <th>Country</th>
             <th>Participants</th>
             <th>Surveys</th>
             <th>SMILE Consent</th>
             <th>SMILE Contact Info Form - Baseline</th>
             <th>SMILE Survey - Baseline</th>
             <th>Safety Planning</th>
           </tr>
         </thead>

         <tbody>
           <tr v-for="(countryData, country, index) in participantsPerCountry" :key="country">
             <td class="link-primary" @click="showCountry(country)">{{country}}</td>
             <td>{{countryData['participants']}}</td>
             <td>{{countryData['surveys']}}</td>
             <td>{{countryData['SMILE Consent']}}</td>
             <td>{{countryData['SMILE Contact Info Form - Baseline']}}</td>
             <td>{{countryData['SMILE Survey - Baseline']}}</td>
             <td>{{countryData['Safety Planning']}}</td>
           </tr>
         </tbody>
       </table>
     </div>

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
     country: null,
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
       axios.get(`${this.$basePrefix}participants`).then(response => {
         this.participantsPerCountry = response.data;
         this.loaded = true;
       });
     },
     showCountry(country) {
       this.country = country;
       this.$emit("countryname", this.country);
     }
   },

 };
</script>

<style scoped>
h3 {
  font-size: 2em;
  text-align: center;
}
</style>
