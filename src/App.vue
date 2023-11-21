<template>
  <div class="flex dark:bg-gray-900 sm:h-screen">
    <div class="m-auto px-6 lg:px-8">
      <div class="mx-auto max-w-3xl">
        <div v-if="!uploaded">
          <h1 class="text-3xl text-center font-bold">CSRO Timesheet Parser</h1>
          <form class="my-4">
            <div class="flex items-center">
              <label
                for="fileUpload"
                class="relative cursor-pointer rounded-md font-bold text-white focus-within:outline-none focus-within:ring-2 focus-within:ring-blue-600 focus-within:ring-offset-2 hover:bg-blue-700 px-2 py-2 bg-blue-600 mx-auto"
              >
                <span>Upload JSON</span>
                <input
                  id="fileUpload"
                  name="file-upload"
                  type="file"
                  class="sr-only"
                  @change="handleFileUpload"
                />
              </label>
            </div>
          </form>
        </div>
        <div v-if="uploaded">
          <h2 class="text-xl font-semibold mt-4">Uploaded Data:</h2>
          <pre>{{ output }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  components: {},
  data() {
    return {
      output: [],
      uploaded: false
    }
  },
  methods: {
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
    handleFileUpload(event) {
      const file = event.target.files[0]

      if (file) {
        const reader = new FileReader()

        reader.onload = () => {
          try {
            const jsonData = JSON.parse(reader.result)
            this.output = jsonData
          } catch (error) {
            console.error('Error parsing JSON:', error)
            // You might want to handle the error in a user-friendly way
          }
        }
        reader.readAsText(file)
      }
      this.uploaded = true
    }
  }
}
</script>
