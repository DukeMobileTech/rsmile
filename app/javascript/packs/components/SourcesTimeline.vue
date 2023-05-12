<template>
  <div v-if="loaded" :key="'source-table'">
    <h5>Participants recruited by source per week</h5>
    <div class="table-responsive">
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
      axios.get(`${this.$basePrefix}participants/weekly_stats`, { params: {country: this.countryName } })
          .then(response => {
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
      this.$parent.setShowSource(false);
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