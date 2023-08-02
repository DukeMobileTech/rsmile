<template>
  <div>
    <div class="card mb-5">
      <div class="card-header">
        <div class="row">
          <div class="col-sm-10">
            <h3 class="card-title">Summary Statistics</h3>
          </div>
          <div class="col-sm-2">
            <a target="_blank" href="https://duke.qualtrics.com/jfe/form/SV_eD1GmFtnKeck474" class="btn btn-outline-primary">Test Survey</a>
          </div>
        </div>
      </div>

      <div class="card-body">
        <div v-if="loaded" class="table-responsive">
          <table class="table card-table table-hover">
            <thead>
              <tr>
                <th>Country</th>
                <th onmouseover='this.style.textDecoration="underline"' onmouseout='this.style.textDecoration="none"' class="text-info" title="Represents the total number of consent surveys that were completed by participants (ineligible + consented + not consented).">Consent</th>
                <th onmouseover='this.style.textDecoration="underline"' onmouseout='this.style.textDecoration="none"' class="text-info" title="Represents the total number of unique participants (based on email addresses) that submitted their contact details.">Participants</th>
                <th onmouseover='this.style.textDecoration="underline"' onmouseout='this.style.textDecoration="none"' class="text-info" title="Represents the total number of participants who submitted their contact details (email address and phone number). Includes both eligible and ineligible participants.">Contact</th>
                <th onmouseover='this.style.textDecoration="underline"' onmouseout='this.style.textDecoration="none"' class="text-info" title="Represents the total number of participants who completed at a minimum the Introduction section of the survey.">Baseline</th>
                <th onmouseover='this.style.textDecoration="underline"' onmouseout='this.style.textDecoration="none"' class="text-info" title="Represents the total number of participants who completed at a minimum the Introduction section of the survey.">Safety Planning</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="(countryData, country, index) in participantsPerCountry" :key="country">
                <td class="link-primary" @click="showCountry(country)">{{country}}</td>
                <td>{{countryData['SMILE Consent']}}</td>
                <td>{{countryData['participants']}}</td>
                <td>{{countryData['SMILE Contact Info Form - Baseline']}}</td>
                <td>{{countryData['SMILE Survey - Baseline']}}</td>
                <td>{{countryData['Safety Planning']}}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else class="text-center">
          <b-spinner type="grow" variant="primary"></b-spinner>
        </div>
      </div>
    </div>
    <Participants />
  </div>
</template>

<script>
  import axios from 'axios';
  import Participants from './Participants'

 export default {
   name: 'Home',

   data: () => ({
     participantsPerCountry: {},
     loaded: false,
     country: null,
   }),

   components: {
      Participants,
   },

   created: function () {
     this.fetchParticipants();
   },

   methods: {
     fetchParticipants () {
       this.loaded = false;
       axios.get(`${this.$basePrefix}participants`)
       .then(response => {
          if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
            window.location.reload();
          }
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
