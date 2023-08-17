<template>
  <div>
    <h5>Mobilizer Recruitment</h5>
    <div v-if="loaded">
      <div class="table-responsive">
        <table class="table table-hover">
          <thead>
            <tr>
              <th>ID</th>
              <th>Baselines</th>
              <th>Duplicates</th>
              <th>Participants</th>
              <th>Avg Participant Baselines</th>
              <th>Avg Duration (minutes)</th>
              <th># Ip Addresses</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="mobilizer in mobilizers" :key="mobilizer.code">
              <td>{{ mobilizer.code }}</td>
              <td>{{ mobilizer.survey_count }}</td>
              <td>{{ mobilizer.duplicate_count }}</td>
              <td>{{ mobilizer.participant_count }}</td>
              <td v-bind:style=" { backgroundColor: mobilizer.average_participant_baselines > 1.09 ? 'red' : 'green' }">
                {{ mobilizer.average_participant_baselines }}
              </td>
              <td v-bind:style=" { backgroundColor: mobilizer.average_duration < 10 ? 'red' : 'green' }">
                {{ mobilizer.average_duration }}
              </td>
              <td v-bind:style=" { backgroundColor: mobilizer.ip_address_count < mobilizer.participant_count ? 'red' : 'green' }">
                {{ mobilizer.ip_address_count }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-else class="text-center">
      <b-spinner type="grow" variant="primary"></b-spinner>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'Mobilizers',
  props: {
    countryName: String,
  },
  data() {
    return {
      loaded: false,
      mobilizers: [],
    };
  },
  mounted: function () {
    this.fetchData();
  },
  methods: {
    fetchData() {
      this.loaded = false;
      axios.get(`${this.$basePrefix}survey_responses/mobilizers`, { params: {country: this.countryName } })
      .then(response => {
        if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
          window.location.reload();
        }
        this.mobilizers = response.data;
        this.loaded = true;
      })
      .catch(error => {
        console.log(error);
      });
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
