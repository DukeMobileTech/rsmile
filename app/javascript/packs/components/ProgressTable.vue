<template>
  <div class="table-responsive">
    <table class="table table-hover">
      <thead>
        <tr>
          <th>SGM Group</th>
          <th>Recruited</th>
          <th>Target</th>
          <th>Progress</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(value, key, index) in dataObj" :key="index">
          <td>{{key}}</td>
          <td>{{value}}</td>
          <td>500</td>
          <td>{{((value / 500) * 100).toFixed(1)}} %</td>
        </tr>
        <tr>
          <td><strong>Total</strong></td>
          <td><strong>{{sum}}</strong></td>
          <td><strong>3500</strong></td>
          <td><strong>{{progress}} %</strong></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: 'ProgressTable',

  props: {
      dataObj: Object,
  },

  data: () => ({
    sum: 0,
    progress: 0,
  }),

  created: function () {
    this.computeData();
  },

  methods: {
    computeData() {
      this.sum = Object.values(this.dataObj).reduce((ps, v) => ps + v, 0);
      this.progress = ((this.sum / 3500) * 100).toFixed(1);
    }
  },
}
</script>
