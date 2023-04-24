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
        <tr v-for="(value, key, index) in dataObj" :key="key">
          <td>{{key}}</td>
          <td>{{value}}</td>
          <td v-if="['ineligible', 'blank', 'no group'].includes(key)"></td>
          <td v-else>500</td>
          <td v-if="['ineligible', 'blank', 'no group'].includes(key)"></td>
          <td v-else> {{((value / 500) * 100).toFixed(1)}} %</td>
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
}
</script>
