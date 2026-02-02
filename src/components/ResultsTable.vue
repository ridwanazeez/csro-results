<template>
  <div class="flex">
    <div class="container m-auto py-12">
      <div class="mb-4 flex justify-end">
        <button
          @click="captureScreenshot"
          class="rounded-md bg-blue-600 hover:bg-blue-700 px-4 py-2 text-white font-medium"
        >
          📸 Save Screenshot
        </button>
      </div>
      <div id="resultsTable" class="bg-white">
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
            {{ resultsTitle || 'Qualifying Results' }}
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
            {{ resultsTitle || 'Race Results' }}
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
                draggable="true"
                @dragstart="handleDragStart($event, resultIndex)"
                @dragover.prevent="handleDragOver($event, resultIndex)"
                @drop="handleDrop($event, resultIndex)"
                @dragend="handleDragEnd"
                class="hover:bg-gray-50 dark:hover:bg-gray-700 cursor-move"
                :class="{ 'opacity-50': draggedIndex === resultIndex }"
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
                    :value="getDriverNation(result.DriverName)"
                    class="w-100 ring-0 rounded-md border-0 py-1.5 text-gray-900 sm:text-sm sm:leading-6 text-center"
                  >
                    <option value="" disabled>COUNTRY</option>
                    <option value="Anguilla">Anguilla</option>
                    <option value="Antigua and Barbuda">Antigua and Barbuda</option>
                    <option value="Bahamas">Bahamas</option>
                    <option value="Barbados">Barbados</option>
                    <option value="Belize">Belize</option>
                    <option value="Bermuda">Bermuda</option>
                    <option value="British Virgin Islands">British Virgin Islands</option>
                    <option value="Canada">Canada</option>
                    <option value="Cayman Islands">Cayman Islands</option>
                    <option value="Cuba">Cuba</option>
                    <option value="Denmark">Denmark</option>
                    <option value="Dominica">Dominica</option>
                    <option value="Grenada">Grenada</option>
                    <option value="Guyana">Guyana</option>
                    <option value="Haiti">Haiti</option>
                    <option value="Jamaica">Jamaica</option>
                    <option value="Montserrat">Montserrat</option>
                    <option value="South Africa">South Africa</option>
                    <option value="Saint Lucia">Saint Lucia</option>
                    <option value="St. Kitts and Nevis">St. Kitts and Nevis</option>
                    <option value="St. Vincent and the Grenadines">
                      St. Vincent and the Grenadines
                    </option>
                    <option value="Suriname">Suriname</option>
                    <option value="Trinidad & Tobago">Trinidad & Tobago</option>
                    <option value="Turks and Caicos Islands">Turks and Caicos Islands</option>
                    <option value="USA">USA</option>
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
import html2canvas from 'html2canvas'

export default {
  data() {
    return {
      tableData: '',
      seriesTitle: null,
      resultsTitle: '',
      seriesLogo: null,
      draggedIndex: null,
      dragOverIndex: null
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
    },
    getDriverNation(driverName) {
      if (!this.tableData.Cars) return ''

      // Find the driver in the Cars array
      const car = this.tableData.Cars.find((car) => car.Driver && car.Driver.Name === driverName)

      if (car && car.Driver && car.Driver.Nation) {
        // Convert nation code to full country name
        return this.getNationName(car.Driver.Nation)
      }

      return ''
    },
    getNationName(nationCode) {
      // Map nation codes to full country names
      const nationMap = {
        GUY: 'Guyana',
        JAM: 'Jamaica',
        TTO: 'Trinidad & Tobago',
        BRB: 'Barbados',
        BHS: 'Bahamas',
        ATG: 'Antigua and Barbuda',
        DMA: 'Dominica',
        GRD: 'Grenada',
        KNA: 'St. Kitts and Nevis',
        LCA: 'Saint Lucia',
        VCT: 'St. Vincent and the Grenadines',
        BLZ: 'Belize',
        SUR: 'Suriname',
        HTI: 'Haiti',
        CUB: 'Cuba',
        CAN: 'Canada',
        USA: 'USA',
        MSR: 'Montserrat',
        AIA: 'Anguilla',
        VGB: 'British Virgin Islands',
        CYM: 'Cayman Islands',
        TCA: 'Turks and Caicos Islands',
        BMU: 'Bermuda',
        DNK: 'Denmark',
        ZAF: 'South Africa'
      }

      return nationMap[nationCode] || ''
    },
    handleDragStart(event, index) {
      this.draggedIndex = index
      event.dataTransfer.effectAllowed = 'move'
      event.dataTransfer.setData('text/html', event.target.innerHTML)
    },
    handleDragOver(event, index) {
      event.preventDefault()
      this.dragOverIndex = index
    },
    handleDrop(event, dropIndex) {
      event.preventDefault()
      if (this.draggedIndex === null || this.draggedIndex === dropIndex) {
        return
      }

      const results = [...this.tableData.Result]
      const draggedItem = results[this.draggedIndex]

      // Remove dragged item
      results.splice(this.draggedIndex, 1)

      // Insert at new position
      results.splice(dropIndex, 0, draggedItem)

      this.tableData.Result = results
      this.saveDataToLocalStorage(this.tableData)
    },
    handleDragEnd() {
      this.draggedIndex = null
      this.dragOverIndex = null
    },
    async captureScreenshot() {
      const element = document.getElementById('resultsTable')
      if (!element) {
        console.error('Results table element not found')
        return
      }

      try {
        // Temporarily add padding for screenshot
        element.style.padding = '2.5rem'

        const canvas = await html2canvas(element, {
          backgroundColor: '#ffffff',
          scale: 2,
          logging: false,
          useCORS: true
        })

        // Remove padding after capture
        element.style.padding = ''

        // Convert canvas to blob
        canvas.toBlob((blob) => {
          // Create download link
          const url = URL.createObjectURL(blob)
          const link = document.createElement('a')
          const date = new Date().toISOString().split('T')[0]
          link.download = `csro-results-${date}.png`
          link.href = url
          link.click()

          // Cleanup
          URL.revokeObjectURL(url)
        })
      } catch (error) {
        console.error('Error capturing screenshot:', error)
        // Make sure to remove padding even if error occurs
        element.style.padding = ''
      }
    }
  },
  mounted() {
    this.loadDataFromLocalStorage()
    if (this.raceData) {
      this.seriesTitle = this.raceData.seriesTitle
      this.resultsTitle = this.raceData.resultsTitle || ''
      this.seriesLogo = this.raceData.seriesLogo
    }
  }
}
</script>
