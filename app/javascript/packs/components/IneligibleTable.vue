<template>
  <div class="table-responsive">
    <table class="table table-hover">
      <thead>
        <tr>
          <th>SGM Group</th>
          <th>Recruited</th>
          <th v-if="sum != 0">Percentage</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(value, key, index) in dataObj" :key="index">
          <td>{{key}}</td>
          <td>{{value}}</td>
          <td v-if="loaded && sum != 0">{{((value / sum) * 100).toFixed(1)}} %</td>
        </tr>
        <tr>
          <td><strong>Total</strong></td>
          <td v-if="loaded"><strong>{{sum}}</strong></td>
          <td v-if="sum != 0"><strong>100 %</strong></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: 'IneligibleTable',

  props: {
      dataObj: Object,
  },

  data: () => ({
    sum: 0,
    progress: 0,
    loaded: false,
  }),

  created: function () {
    this.computeData();
  },

  watch: {
    dataObj: function () {
      this.computeData();
    }
  },

  methods: {
    computeData() {
      this.loaded = false;
      this.sum = Object.values(this.dataObj).reduce((ps, v) => ps + v, 0);
      this.loaded = true;
    }
  },
}
</script>
