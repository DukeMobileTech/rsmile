<template>
  <div>
    <h5>Mobilizer Recruitment</h5>
    <div v-if="loaded">
      <b-table sticky-header="500px" responsive
        label-sort-asc="" label-sort-desc="" label-sort-clear=""
        :items="compMobilizers" :fields="fields">
      </b-table>
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
      sortBy: 'code',
      fields: [
        {key: 'code', label: 'ID', sortable: true, stickyColumn: true, variant: 'info'},
        {key: 'baseline_count', label: 'Baselines', sortable: true},
        {key: 'duplicate_count', label: 'Duplicates', sortable: true},
        {key: 'participant_count', label: 'Participants', sortable: true},
        {key: 'participant_count_with_duplicates', label: 'Parts w/ Dups', sortable: true},
        {key: 'average_baselines_for_participants_with_duplicates', label: 'Avg Dups / Parts w/ Dups', sortable: true},
        {key: 'average_duration', label: 'Avg Duration (minutes)', sortable: true},
        {key: 'ip_address_count', label: 'Ip Addresses', sortable: true},
        {key: 'accepted_participant_count', label: 'Accepted Participants', sortable: true},
        {key: 'group_a_count', label: 'Group A', sortable: true},
        {key: 'group_b_count', label: 'Group B', sortable: true},
        {key: 'group_c_count', label: 'Group C', sortable: true},
      ]
    };
  },
  computed: {
    compMobilizers() {
      let items = this.mobilizers.map(mobilizer => {
        return {
          ...mobilizer,
          _cellVariants: {
            average_duration: mobilizer.average_duration < 10 ? 'danger' : null, 
            average_baselines_for_participants_with_duplicates: 
              mobilizer.average_baselines_for_participants_with_duplicates >= 2 ? 'danger' : null,
            ip_address_count: mobilizer.ip_address_count < mobilizer.participant_count ? 'danger' : null,
            participant_count_with_duplicates: mobilizer.participant_count_with_duplicates > 0 ? 'danger' : null,
          }
        };
      });
      items.push({
        code: 'Totals',
        baseline_count: items.reduce((a, b) => a + b.baseline_count, 0),
        duplicate_count: items.reduce((a, b) => a + b.duplicate_count, 0),
        participant_count: items.reduce((a, b) => a + b.participant_count, 0),
        accepted_participant_count: items.reduce((a, b) => a + b.accepted_participant_count, 0),
        _rowVariant: 'info',
      });
      return items;
    }
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
