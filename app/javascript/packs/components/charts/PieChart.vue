<script>
  import { Pie } from 'vue-chartjs'

  export default {
    extends: Pie,

    name: 'PieChart',

    props: {
      chartdata: {
        type: Object,
        default: null
      },
      options: {
        type: Object,
        default: null
      }
    },

    mounted: function () {
      this.renderChart(this.chartdata, this.options);
    }
  }

</script>
