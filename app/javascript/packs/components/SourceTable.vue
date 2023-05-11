<template>
  <div :key="'source-table'">
    <button type="button" class="btn btn-link" @click="goBack">See Other Sources</button>
    <h6>{{this.$parent.namedSource(source)}}</h6>
    <div class="table-responsive">
      <table class="table table-hover">
        <thead>
          <tr>
            <th v-for="(week, index) in weeks" :key="index">{{week}}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td v-for="(count, index) in counts" :key="index">{{count}}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
   name: 'SourceTable', 

   data: () => ({
      weeks: [],
      counts: [],
      loaded: false,
    }),

   props: {
        countryName: String,
        source: String,
        showSource: Boolean,
    },

  created: function () {
    this.fetchWeeklySourceData();
  },

  methods: {
      fetchWeeklySourceData() {
        this.loaded = false;
        axios.get(`${this.$basePrefix}participants/source_timeline`, { params: {country: this.countryName, source: this.source } })
             .then(response => {
                response.data.forEach((datum) => {
                  this.weeks.push(Object.keys(datum)[0]);
                  this.counts.push(Object.values(datum)[0]);
                });
                this.loaded = true;
             });
      },
      goBack() {
        this.$parent.setShowSource(false);
      }
    },
}
</script>

<style scoped>
h6 {
  font-size: 1em;
  text-align: center;
}
</style>