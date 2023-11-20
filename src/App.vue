<template>
  <div class="container">
    <h1>CSRO Timesheet Parser</h1>
    <div class="d-flex flex-column justify-content-center align-items-center">
      <div class="col-4">
        <form id="form">
          <div class="mb-3">
            <label for="fileUpload" class="form-label">Upload JSON File</label>
            <input type="file" class="form-control" id="fileUpload" @change="handleFile" />
          </div>
        </form>
      </div>
    </div>
    <Table :data="output" :laps="bestLap" :totaltime="totalTime" />
  </div>
  <h1 class="text-3xl font-bold underline">Hello world!</h1>
</template>

<script>
export default {
  components: {},
  data() {
    return {
      output: [],
      bestLap: [],
      totalTime: []
    }
  },
  methods: {
    handleFile(e) {
      let files = e.target.files || e.dataTransfer.files
      if (!files.length) return
      this.readFile(files[0])
    },
    calculateBestLap(x) {
      //Time calculation
      //Some steps below are a bit repetitive because of how numbers work in JS
      var a = x / 1000 //milliseconds after decimal point
      var b = a.toString() //converts to string
      var c = parseInt(b) //converted time back to integer, removes decimal without rounding
      var ms = (c - a) * 1000 //milliseconds, but as a large decimal
      ms = Math.abs(ms).toFixed(0) //absolute value of milliseconds (round number and removes decimal)
      var seconds = c % 60 //remainder after dividing by 60 to get seconds of laptime
      var minutes = (c - seconds) / 60 //subtract seconds from time at C (to avoid decimals) then divided by 60 to get lap minutes

      //console.log(a, b, c, ms, seconds, minutes); //test output

      //Time output
      if (minutes > 0) {
        //eg. 1:11:111
        if (seconds < 10) {
          //eg. 1:01:111
          if (ms < 100) {
            //eg. 1:01:011
            if (ms < 10) {
              //eg. 1:01:001
              return '' + minutes + ':0' + seconds + ':00' + ms //return 1:01:001
            } else {
              return '' + minutes + ':0' + seconds + ':0' + ms //return 1:01:011
            }
          } else {
            return '' + minutes + ':0' + seconds + ':' + ms //return 1:01:111
          }
        } else {
          if (ms < 100) {
            //eg. 1:01:011
            if (ms < 10) {
              //eg. 1:01:001
              return '' + minutes + ':' + seconds + ':00' + ms //return 1:11:001
            } else {
              return '' + minutes + ':' + seconds + ':0' + ms //return 1:11:011
            }
          } else {
            return '' + minutes + ':' + seconds + ':' + ms //return 1:11:111
          }
        }
      } else {
        //eg. 11:111
        if (seconds < 10) {
          //eg. 1:01:111
          if (ms < 100) {
            //eg. 1:01:011
            if (ms < 10) {
              //eg. 1:01:001
              return '0' + seconds + ':00' + ms //return 1:01:001
            } else {
              return '0' + seconds + ':0' + ms //return 1:01:011
            }
          } else {
            return '0' + seconds + ':' + ms //return 1:01:111
          }
        } else {
          if (ms < 100) {
            //eg. 1:01:011
            if (ms < 10) {
              //eg. 1:01:001
              return seconds + ':00' + ms //return 1:11:001
            } else {
              return seconds + ':0' + ms //return 1:11:011
            }
          } else {
            return seconds + ':' + ms //return 1:11:111
          }
        }
      }
    },
    readFile(file) {
      let reader = new FileReader()
      reader.onload = (e) => {
        this.output = JSON.parse(e.target.result).Result

        //extra code that converts the int time to MM:SS:ms
        let json = JSON.parse(e.target.result).Result
        var length = Object.keys(json).length
        for (var i = 0; i <= length; i++) {
          this.bestLap[i] = this.calculateBestLap(json[i].BestLap)
        }
      }
      reader.readAsText(file)
    }
  }
}
</script>
