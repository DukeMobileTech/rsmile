<template>
  <div>
    <div v-if="loaded">
      <b-table
        sticky-header="600px"
        bordered
        responsive
        striped
        hover
        foot-clone
        label-sort-asc=""
        label-sort-desc=""
        label-sort-clear=""
        :items="agencies"
        :fields="fields"
      >
        <!-- Additional header row -->
        <template #thead-top="data">
          <b-tr>
            <b-th colspan="2"> </b-th>
            <b-th variant="secondary" colspan="13" class="text-center">
              Recruitment Source
            </b-th>
          </b-tr>
        </template>
        <!-- A custom formatted cell for field 'group' -->
        <template #cell(group)="data">
          <b>{{ getGroup(data.value) }}</b>
        </template>
        <!-- A custom formatted footer cell -->
        <template #foot()="data">
          <b>{{ getFooter(data.label) }}</b>
        </template>
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
  name: 'Agencies',
  data() {
    return {
      loaded: false,
      agencies: [],
      fields: [],
    };
  },
  props: {
    countryName: String,
  },
  mounted: function () {
    this.fetchData();
  },
  methods: {
    fetchData: function () {
      axios
        .get(`${this.$basePrefix}survey_responses/agencies`, {
          params: {
            country: this.countryName,
          },
        })
        .then((response) => {
          this.agencies = response.data;
          this.fields = this.getKeys();
          this.loaded = true;
        })
        .catch((error) => {
          console.log(error);
        });
    },
    getSource: function (source) {
      return this.$SOURCES[source];
    },
    getKeys: function () {
      let keys = [
        {
          key: 'group',
          label: 'SGM Group',
          sortable: true,
          stickyColumn: true,
        },
        { key: 'recruited', label: 'Participants Recruited', sortable: true },
      ];
      for (let i = 12; i <= 24; i++) {
        keys.push({
          key: `${i}`,
          label: this.$SOURCES[i],
          sortable: true,
        });
      }
      return keys;
    },
    getGroup: function (group) {
      return this.$SGM_LABELS[group];
    },
    getFooter: function (label) {
      if (label == 'SGM Group') {
        return 'Totals';
      } else if (label == 'Participants Recruited') {
        return this.agencies.reduce((a, b) => a + b.recruited, 0);
      } else {
        return this.agencies.reduce(
          (a, b) => a + b[this.getSourceByLabel(label)],
          0
        );
      }
    },
    getSourceByLabel: function (label) {
      return Object.keys(this.$SOURCES).find(
        (key) => this.$SOURCES[key] === label
      );
    },
  },
};
</script>
<style></style>
