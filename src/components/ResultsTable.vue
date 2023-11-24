<template>
  <div class="flex">
    <div class="container m-auto py-12">
      <div id="resultsTable">
        <div class="flex align-middle items-center mb-5">
          <img class="w-1/4 mx-auto" src="/images/csro-logo.png" alt="CSRO Logo" />
          <img
            v-if="seriesLogo"
            class="w-1/4 mx-auto"
            :src="seriesLogo"
            alt="CSRO Racing Series Logo"
          />
          <img v-else class="w-1/4 mx-auto" src="/images/csro-logo.png" alt="CSRO Logo" />
        </div>
        <div
          v-if="tableData.Type == 'QUALIFY'"
          class="relative mb-5 flex w-full flex-col items-center text-center"
        >
          <h1 class="items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
            {{ seriesTitle }}
          </h1>
          <h1 class="items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
            Qualifying Results
          </h1>
          <h2 class="flex items-center tracking-tight text-black">
            {{ formatDate(tableData.Date) }}
          </h2>
        </div>
        <div v-else class="relative mb-5 flex w-full flex-col items-center text-center">
          <h1 class="items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
            {{ seriesTitle }}
          </h1>
          <h1 class="items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
            Race Results
          </h1>
          <h2 class="flex items-center tracking-tight text-black">
            {{ formatDate(tableData.Date) }}
          </h2>
        </div>
        <div class="overflow-hidden rounded-lg border border-gray-200 shadow-md dark:border-white">
          <table
            class="w-full border-collapse bg-white text-left text-sm text-gray-500 dark:bg-gray-800 dark:text-white table-auto"
          >
            <thead class="bg-gray-50 dark:bg-gray-800">
              <tr>
                <th
                  scope="col"
                  class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
                >
                  #
                </th>
                <th scope="col" class="px-6 py-4 font-medium text-gray-900 dark:text-white">
                  Name
                </th>
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
                  v-if="tableData.Type == 'QUALIFY'"
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
                <th class="px-6 py-4 font-bold text-center">{{ resultIndex + 1 }}</th>
                <td
                  contenteditable="true"
                  class="px-6 py-4 font-normal text-gray-900 dark:text-white"
                >
                  {{ result.DriverName }}
                </td>
                <td contenteditable="true" class="px-6 py-4 text-center">
                  <select
                    id="country"
                    name="country"
                    class="w-100 ring-0 rounded-md border-0 py-1.5 text-gray-900 sm:text-sm sm:leading-6 text-center"
                  >
                    <option selected disabled>COUNTRY</option>
                    <option>Anguilla</option>
                    <option>Antigua and Barbuda</option>
                    <option>Bahamas</option>
                    <option>Barbados</option>
                    <option>Belize</option>
                    <option>Bermuda</option>
                    <option>British Virgin Islands</option>
                    <option>Canada</option>
                    <option>Cayman Islands</option>
                    <option>Cuba</option>
                    <option>Denmark</option>
                    <option>Dominica</option>
                    <option>Grenada</option>
                    <option>Guyana</option>
                    <option>Haiti</option>
                    <option>Jamaica</option>
                    <option>Montserrat</option>
                    <option>South Africa</option>
                    <option>Saint Lucia</option>
                    <option>St. Kitts and Nevis</option>
                    <option>St. Vincent and the Grenadines</option>
                    <option>Suriname</option>
                    <option>Trinidad & Tobago</option>
                    <option>Turks and Caicos Islands</option>
                    <option>USA</option>
                  </select>
                </td>
                <td contenteditable="true" class="px-6 py-4 text-center">
                  {{ calculateBestLap(result.TotalTime) }}
                </td>
                <td
                  class="px-6 py-4 text-center"
                  :class="{ 'bg-green-600 text-white': isBestLap(result.BestLap) }"
                >
                  {{ calculateBestLap(result.BestLap) }}
                </td>
                <td v-if="tableData.Type == 'QUALIFY'" class="px-6 py-4 text-center">
                  {{ calculateRaceGap(tableData.Result)[resultIndex] }}
                </td>
                <td class="px-6 py-4 text-center">
                  {{ calculateTotalLaps(tableData.Laps, result.DriverName) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      tableData: '',
      seriesTitle: null,
      seriesLogo: null
    }
  },
  props: {
    raceData: {
      type: Object,
      default: null
    }
  },
  methods: {
    calculateBestLap(x, penalty = 0) {
      //Time calculation
      //Some steps below are a bit repetitive because of how numbers work in JS
      var a = x / 1000 //milliseconds after decimal point
      var b = a.toString() //converts to string
      var c = parseInt(b) //converted time back to integer, removes decimal without rounding
      var ms = (c - a) * 1000 //milliseconds, but as a large decimal
      ms = Math.abs(ms).toFixed(0) //absolute value of milliseconds (round number and removes decimal)
      var seconds = (c % 60) + penalty //remainder after dividing by 60 to get seconds of laptime then add on penalties if any
      var minutes = Math.round((c - seconds) / 60) //subtract seconds from time at C (to avoid decimals) then divided by 60 to get lap minutes

      // console.log('------------')
      // console.log('original: ', x)
      // console.log('ms after decimal point: ', a)
      // console.log('converted to string: ', b)
      // console.log('converted back to int: ', c)
      // console.log('minutes: ', minutes)
      // console.log('seconds: ', seconds)
      // console.log('ms: ', ms)
      // console.log('time penalty: ', penalty)
      // console.log('------------')

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
    calculateRaceGap(results) {
      const raceGap = []

      for (let i = 0; i < results.length; i++) {
        if (i === 0) {
          // For the first row, the race gap is 0
          raceGap.push(this.formatTime(0))
        } else {
          // Calculate the difference between the current lap and the first lap
          const gap = results[i].BestLap - results[0].BestLap
          raceGap.push(this.formatTime(gap))
        }
      }

      return raceGap
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
    isBestLap(currentBestLap) {
      const allBestLaps = this.tableData.Result.map((result) => result.BestLap)
      const smallestBestLap = Math.min(...allBestLaps)
      return currentBestLap === smallestBestLap
    },
    formatTime(milliseconds) {
      const minutes = Math.floor(milliseconds / (60 * 1000))
      const seconds = Math.floor((milliseconds % (60 * 1000)) / 1000)
      const millisecondsPart = milliseconds % 1000

      // Pad single-digit seconds and milliseconds with leading zeros
      const formattedSeconds = seconds < 10 ? `0${seconds}` : `${seconds}`
      const formattedMilliseconds =
        millisecondsPart < 10
          ? `00${millisecondsPart}`
          : millisecondsPart < 100
            ? `0${millisecondsPart}`
            : `${millisecondsPart}`

      return `${minutes}:${formattedSeconds}.${formattedMilliseconds}`
    }
  },
  mounted() {
    this.loadDataFromLocalStorage()
    if (this.raceData) {
      this.seriesTitle = this.raceData.seriesTitle
      this.seriesLogo = this.raceData.seriesLogo
    }
  }
}
</script>
