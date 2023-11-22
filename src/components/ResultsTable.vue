<template>
  <div class="flex">
    <div class="container m-auto py-12">
      <div
        v-if="tableData.Type == 'QUALIFY'"
        class="relative mb-5 flex w-full flex-col items-center text-center"
      >
        <div class="flex align-middle items-center">
          <h1 class="items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
            Qualifying Results
            <button
              class="absolute right-0 ml-2 inline-flex items-center rounded-md bg-red-600 hover:bg-red-700 p-2 text-base text-white"
              @click="clearData()"
            >
              Clear Table Data
            </button>
          </h1>
        </div>
        <h2 class="flex items-center tracking-tight text-black">
          {{ formatDate(tableData.Date) }}
        </h2>
      </div>
      <div v-else class="relative mb-5 flex w-full flex-col items-center text-center">
        <h1 class="flex items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
          Race Results
        </h1>
      </div>
      <div class="overflow-hidden rounded-lg border border-gray-200 shadow-md dark:border-white">
        <table
          class="w-full border-collapse bg-white text-left text-sm text-gray-500 dark:bg-gray-800 dark:text-white"
        >
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th
                scope="col"
                class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
              >
                #
              </th>
              <th scope="col" class="px-6 py-4 font-medium text-gray-900 dark:text-white">Name</th>
              <th
                scope="col"
                class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
              >
                Country
              </th>
              <th
                scope="col"
                class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
              >
                Total Time
              </th>
              <th
                scope="col"
                class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
              >
                Best Lap
              </th>
              <th
                scope="col"
                class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
              >
                Gap
              </th>
              <th
                scope="col"
                class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
              >
                # of Laps
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100 border-t border-gray-100 dark:border-white">
            <tr
              v-for="(result, resultIndex) of tableData.Result"
              :key="resultIndex"
              class="hover:bg-gray-50 dark:hover:bg-gray-700"
            >
              <th class="px-6 py-4 font-bold">{{ resultIndex + 1 }}</th>
              <td class="flex gap-3 px-6 py-4 font-normal text-gray-900 dark:text-white">
                {{ result.DriverName }}
              </td>
              <td class="px-6 py-4 text-center">COUNTRY</td>
              <td class="px-6 py-4 text-center">{{ calculateBestLap(result.TotalTime) }}</td>
              <td class="px-6 py-4 text-center">{{ calculateBestLap(result.BestLap) }}</td>
              <td class="px-6 py-4 text-center"></td>
              <td class="px-6 py-4 text-center">
                {{ calculateTotalLaps(tableData.Laps, result.DriverName) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      tableData: ''
    }
  },
  props: {},
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
              return '' + minutes + ':0' + seconds + '.00' + ms //return 1:01:001
            } else {
              return '' + minutes + ':0' + seconds + '.0' + ms //return 1:01:011
            }
          } else {
            return '' + minutes + ':0' + seconds + '.' + ms //return 1:01:111
          }
        } else {
          if (ms < 100) {
            //eg. 1:01:011
            if (ms < 10) {
              //eg. 1:01:001
              return '' + minutes + ':' + seconds + '.00' + ms //return 1:11:001
            } else {
              return '' + minutes + ':' + seconds + '.0' + ms //return 1:11:011
            }
          } else {
            return '' + minutes + ':' + seconds + '.' + ms //return 1:11:111
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
              return '0' + seconds + '.00' + ms //return 1:01:001
            } else {
              return '0' + seconds + '.0' + ms //return 1:01:011
            }
          } else {
            return '0' + seconds + '.' + ms //return 1:01:111
          }
        } else {
          if (ms < 100) {
            //eg. 1:01:011
            if (ms < 10) {
              //eg. 1:01:001
              return seconds + '.00' + ms //return 1:11:001
            } else {
              return seconds + '.0' + ms //return 1:11:011
            }
          } else {
            return seconds + '.' + ms //return 1:11:111
          }
        }
      }
    },
    calculateTotalLaps(data, driver) {
      let totalLaps = 0
      for (var i = 0; i < data.length; i++) {
        if (data[i].DriverName === driver) {
          totalLaps = totalLaps + 1
          // console.log(data[i].DriverName, driver, totalLaps)
        }
      }
      return totalLaps
    },
    formatDate(inputDate) {
      // Input date string
      const dateString = inputDate

      // Create a new Date object from the input string
      const date = new Date(dateString)

      // Extract day, month, and year
      const day = date.getUTCDate()
      const month = date.getUTCMonth() + 1 // Months are zero-based, so add 1
      const year = date.getUTCFullYear()

      // Format day, month, and year as two-digit strings
      const formattedDay = day < 10 ? '0' + day : day
      const formattedMonth = month < 10 ? '0' + month : month

      // Construct the formatted date string
      const formattedDate = `${formattedDay}-${formattedMonth}-${year}`

      return formattedDate
    },
    loadDataFromLocalStorage() {
      const jsonData = localStorage.getItem('CSRO_RESULT')
      if (jsonData) {
        try {
          this.tableData = JSON.parse(jsonData)
        } catch (error) {
          console.error('Error loading JSON from localStorage:', error)
        }
      }
    },
    saveDataToLocalStorage(data) {
      const jsonData = JSON.stringify(data)
      localStorage.setItem('CSRO_RESULT', jsonData)
    },
    clearData() {
      localStorage.clear()
      window.location.reload()
    }
  },
  mounted() {
    this.loadDataFromLocalStorage()
  }
}
</script>
