<script>
  import { Line } from 'vue-chartjs'

  export default {
    extends: Line,

    name: 'LineChart',

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
