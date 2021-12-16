<template>
  <div class="table-responsive">
    <table class="table table-hover">
      <thead>
        <tr>
          <th>{{firstHeader}}</th>
          <th>{{secondHeader}}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(value, key, index) in dataObj" :key="key">
          <td>{{key}}</td>
          <td>{{value}}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: 'CountryTable',

  props: {
      dataObj: Object,
      firstHeader: String,
      secondHeader: String,
  },
}
</script>
