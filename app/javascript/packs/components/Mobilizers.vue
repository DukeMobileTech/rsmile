<template>
  <div>
    <div v-if="loaded">
      <b-table sticky-header="600px" responsive striped hover
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
        {key: 'code', label: 'Mobilizer Code', sortable: true, stickyColumn: true, variant: 'info'},
        {key: 'baseline_count', label: 'Baselines', sortable: true},
        {key: 'duplicate_count', label: 'Duplicates', sortable: true},
        {key: 'participant_count', label: 'All Participants', sortable: true},
        {key: 'participant_count_with_duplicates', label: 'Parts w/ Dups', sortable: true},
        {key: 'average_baselines_for_participants_with_duplicates', label: 'Avg Dups / Parts w/ Dups', sortable: true},
        {key: 'average_duration', label: 'Avg Duration (minutes)', sortable: true},
        {key: 'ip_address_count', label: 'Ip Addresses', sortable: true},
        {key: 'group_a_count', label: 'Group A', sortable: true},
        {key: 'group_b_count', label: 'Group B', sortable: true},
        {key: 'group_c_count', label: 'Group C', sortable: true},
        {key: 'self_gen_id_count', label: 'Self Gen IDs', sortable: true},
        {key: 'sgm_groups', label: 'SGM Groups', sortable: true},
        {key: 'eligible_participant_count', label: 'Eligible Participants', sortable: true},
        {key: 'completed_participant_count', label: 'Participants With Completed Baselines', sortable: true},
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
            completed_participant_count: this.getColor(mobilizer.completed_participant_count),
            self_gen_id_count: mobilizer.self_gen_id_count != mobilizer.participant_count ? 'danger' : null
          }
        };
      });
      items.push({
        code: 'Totals',
        baseline_count: items.reduce((a, b) => a + b.baseline_count, 0),
        duplicate_count: items.reduce((a, b) => a + b.duplicate_count, 0),
        participant_count: items.reduce((a, b) => a + b.participant_count, 0),
        eligible_participant_count: items.reduce((a, b) => a + b.eligible_participant_count, 0),
        completed_participant_count: items.reduce((a, b) => a + b.completed_participant_count, 0),
        _rowVariant: 'info',
      });
      return items;
    }
  },
  mounted: function () {
    this.fetchData();
  },
  methods: {
    getColor(count) {
      if (count == 0) {
        return 'danger'
      } else if (count > 20) {
        return 'warning'
      } else {
        return null
      }
    },
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
