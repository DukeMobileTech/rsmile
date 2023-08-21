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
              <th>Participants w/ Duplicates</th>
              <th>Avg # Dups for Participant w/ Dups</th>
              <th>Avg Duration (minutes)</th>
              <th># Ip Addresses</th>
              <th># Accepted Participants</th>
              <th># Group A</th>
              <th># Group B</th>
              <th># Group C</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="mobilizer in mobilizers" :key="mobilizer.code">
              <td>{{ mobilizer.code }}</td>
              <td>{{ mobilizer.survey_count }}</td>
              <td>{{ mobilizer.duplicate_count }}</td>
              <td>{{ mobilizer.participant_count }}</td>
              <td v-bind:style=" { color: mobilizer.participant_count_with_duplicates > 0 ? 'red' : 'black' }">
                {{ mobilizer.participant_count_with_duplicates }}
              </td>
              <td v-bind:style=" { color: mobilizer.average_participant_baselines > 1.09 ? 'red' : 'black' }">
                {{ mobilizer.average_participant_baselines }}
              </td>
              <td v-bind:style=" { color: mobilizer.average_duration < 10 ? 'red' : 'black' }">
                {{ mobilizer.average_duration }}
              </td>
              <td v-bind:style=" { color: mobilizer.ip_address_count < mobilizer.participant_count ? 'red' : 'black' }">
                {{ mobilizer.ip_address_count }}
              </td>
              <td>{{ mobilizer.accepted_participant_count }}</td>
              <td>{{ mobilizer.group_a_count }}</td>
              <td>{{ mobilizer.group_b_count }}</td>
              <td>{{ mobilizer.group_c_count }}</td>
            </tr>
            <tr v-bind:style=" { 'font-weight': 'bold' }">
              <td>Totals</td>
              <td>{{ mobilizers.reduce((a, b) => a + b.survey_count, 0) }}</td>
              <td>{{ mobilizers.reduce((a, b) => a + b.duplicate_count, 0) }}</td>
              <td>{{ mobilizers.reduce((a, b) => a + b.participant_count, 0) }}</td>
              <td></td>
              <td></td>
              <td></td>
              <td>{{ mobilizers.reduce((a, b) => a + b.accepted_participant_count, 0) }}</td>
              <td></td>
              <td></td>
              <td></td>
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
