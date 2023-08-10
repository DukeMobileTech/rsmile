<template>
  <div class="card mb-5" :key="'source-table'">
    <h5>Eligible participants recruited by source per week - completed the main block of the short survey or the long survey in its entirety</h5>
    <div v-if="loaded" class="table-responsive">
      <table class="table table-hover">
        <thead>
          <tr>
            <th>Source</th>
            <th v-for="(week, index) in weeks" :key="index">{{week}}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(source, sIndex) in sources" :key="sIndex">
            <td>{{source}}</td>
            <td v-for="(count, index) in counts[sIndex]" :key="index">
              {{Object.values(count)[0]}}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else class="text-center">
      <b-spinner type="grow" variant="primary"></b-spinner>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
   name: 'SourcesTimeline', 

   data() {
      return this.initialState();
   },

   props: {
        countryName: String,
    },

  created: function () {
    this.fetchWeeklySourceData();
  },

  methods: {
    initialState() {
        return {
          weeks: [],
          counts: [],
          loaded: false,
          sources: [],
        }
    },
    reset() {
        Object.assign(this.$data, this.initialState());
    },
    fetchWeeklySourceData() {
      this.loaded = false;
      axios.get(`${this.$basePrefix}participants/timeline`, { params: {country: this.countryName } })
          .then(response => {
            if (typeof response.data == "string" && response.data.startsWith("<!DOCTYPE html>")) {
              window.location.reload();
            }
            let sourceIds = Object.keys(response.data);
            let titleRow = response.data[sourceIds[0]];
            if (titleRow) {
              titleRow.forEach((datum) => {
                this.weeks.push(Object.keys(datum)[0]);
              });
            }
            let list = [];
            for (let i = 0; i < 25; i++) {
              list.push(i);
            }
            list.forEach((index) => {
              let sourceData = response.data[index];
              if (sourceData) {
                this.counts.push(sourceData);
                this.sources.push(this.$parent.namedSource(index.toString()));
              }
            });
            this.loaded = true;
          });
    },
    goBack() {
      this.reset();
    },
  },
}
</script>

<style scoped>
h5 {
  font-size: 1.5em;
  text-align: center;
}

.table th:first-child,
.table td:first-child {
  position: sticky;
  left: 0;
  background-color: whitesmoke;
}
</style>