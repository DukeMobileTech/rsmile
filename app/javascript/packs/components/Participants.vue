<template>
  <div class="card mb-5">
    <div class="card-header">
      <h6 class="card-title">Country Recruitment</h6>
    </div>
    <div class="card-body">
      <div v-if="loaded" class="table-responsive">
        <table class="table card-table table-hover mb-3">
          <thead>
            <tr>
              <th>Country</th>
              <th>Recruited</th>
              <th>Eligible</th>
              <th>Ineligible</th>
              <th>Derived</th>
              <th>Excluded</th>
              <th>Contactable</th>
              <th>Accepted</th>
              <th>Progress</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(data, country, index) in summary" :key="country">
              <td class="link-primary" @click="showCountry(country)">
                {{ country }}
              </td>
              <td>{{ data['recruited'] }}</td>
              <td class="text-success">{{ data['eligible'] }}</td>
              <td>{{ data['ineligible'] }}</td>
              <td>{{ data['derived'] }}</td>
              <td class="text-danger">{{ data['excluded'] }}</td>
              <td>{{ data['contactable'] }}</td>
              <td class="text-success">{{ data['accepted'] }}</td>
              <td
                v-bind:style="{
                  backgroundColor: getColor((data['accepted'] / 3500) * 100),
                }"
              >
                {{ ((data['accepted'] / 3500) * 100).toFixed(2) }} %
              </td>
            </tr>
            <tr>
              <td><strong>Total</strong></td>
              <td>
                <strong>{{ total['recruited'] }}</strong>
              </td>
              <td class="text-success">
                <strong>{{ total['eligible'] }}</strong>
              </td>
              <td>
                <strong>{{ total['ineligible'] }}</strong>
              </td>
              <td>
                <strong>{{ total['derived'] }}</strong>
              </td>
              <td class="text-danger">
                <strong>{{ total['excluded'] }}</strong>
              </td>
              <td>
                <strong>{{ total['contactable'] }}</strong>
              </td>
              <td class="text-success">
                <strong>{{ total['accepted'] }}</strong>
              </td>
              <td v-bind:style="{ backgroundColor: getColor(progress()) }">
                <strong>{{ progress().toFixed(2) + ' %' }}</strong>
              </td>
            </tr>
          </tbody>
        </table>
        <Definitions />
      </div>
      <div v-else class="text-center">
        <b-spinner type="grow" variant="primary"></b-spinner>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import Definitions from './Definitions';

export default {
  name: 'Participants',

  data: () => ({
    summary: {},
    loaded: false,
    total: {
      recruited: 0,
      eligible: 0,
      ineligible: 0,
      derived: 0,
      excluded: 0,
      contactable: 0,
      accepted: 0,
    },
  }),

  components: {
    Definitions,
  },

  created: function () {
    this.fetchSummary();
  },

  methods: {
    fetchSummary() {
      this.loaded = false;
      axios.get(`${this.$basePrefix}participants`).then((response) => {
        if (
          typeof response.data == 'string' &&
          response.data.startsWith('<!DOCTYPE html>')
        ) {
          window.location.reload();
        }
        this.summary = response.data;
        this.calculateTotals();
        this.loaded = true;
      });
    },
    showCountry(country) {
      // $parent is Home.vue which emits it to its parent App.vue which is listening for it
      this.$parent.$emit('countryname', country);
    },
    calculateTotals() {
      for (let country in this.summary) {
        this.total.recruited += this.summary[country]['recruited'];
        this.total.eligible += this.summary[country]['eligible'];
        this.total.ineligible += this.summary[country]['ineligible'];
        this.total.derived += this.summary[country]['derived'];
        this.total.excluded += this.summary[country]['excluded'];
        this.total.contactable += this.summary[country]['contactable'];
        this.total.accepted += this.summary[country]['accepted'];
      }
    },
    progress() {
      return (this.total.accepted / 10000) * 100;
    },
    getColor(progress) {
      if (progress < 33.0) {
        return '#f5c6cb';
      } else if (progress >= 33.0 && progress < 66.0) {
        return '#ffeeba';
      } else {
        return '#c3e6cb';
      }
    },
  },
};
</script>

<style scoped>
h6 {
  font-size: 1.5em;
  text-align: center;
}
</style>
