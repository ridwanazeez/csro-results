<template>
  <div class="flex">
    <div class="m-auto py-12">
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
            {{ resultsTitle || 'Results' }}
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
            {{ resultsTitle || 'Results' }}
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
                  Team
                </th>
                <th
                  scope="col"
                  class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
                >
                  Car
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
                <th
                  v-if="tableData.Type == 'RACE'"
                  scope="col"
                  class="px-6 py-4 font-medium text-gray-900 dark:text-white text-center"
                >
                  Points
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
                  :data-field="'name'"
                  :data-index="resultIndex"
                  class="px-6 py-4 font-normal text-gray-900 dark:text-white"
                  @blur="handleCellEdit"
                >
                  {{ result.DriverName }}
                </td>
                <td class="px-6 py-4 text-center">
                  <select
                    id="country"
                    name="country"
                    :value="getDriverNation(result.DriverName)"
                    :data-index="resultIndex"
                    @change="handleCountryChange"
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
                <td
                  contenteditable="true"
                  :data-field="'team'"
                  :data-index="resultIndex"
                  class="px-6 py-4 text-center"
                  @blur="handleCellEdit"
                >
                  {{ getDriverTeam(result.DriverName) }}
                </td>
                <td
                  contenteditable="true"
                  :data-field="'car'"
                  :data-index="resultIndex"
                  class="px-6 py-4 text-center"
                  @blur="handleCellEdit"
                >
                  {{ getDriverCar(result.DriverName) }}
                </td>
                <td
                  contenteditable="true"
                  :data-field="'totalTime'"
                  :data-index="resultIndex"
                  class="px-6 py-4 text-center"
                  @blur="handleCellEdit"
                >
                  {{ result.customTotalTime || calculateBestLap(result.TotalTime) }}
                </td>
                <td
                  contenteditable="true"
                  :data-field="'bestLap'"
                  :data-index="resultIndex"
                  class="px-6 py-4 text-center"
                  :class="{ 'bg-green-600 text-white': isBestLap(result.BestLap) }"
                  @blur="handleCellEdit"
                >
                  {{ result.customBestLap || calculateBestLap(result.BestLap) }}
                </td>
                <td
                  v-if="tableData.Type == 'QUALIFY'"
                  contenteditable="true"
                  :data-field="'gap'"
                  :data-index="resultIndex"
                  class="px-6 py-4 text-center"
                  @blur="handleCellEdit"
                >
                  {{ result.customGap || calculateRaceGap(tableData.Result)[resultIndex] }}
                </td>
                <td
                  contenteditable="true"
                  :data-field="'laps'"
                  :data-index="resultIndex"
                  class="px-6 py-4 text-center"
                  @blur="handleCellEdit"
                >
                  {{ result.customLaps || calculateTotalLaps(tableData.Laps, result.DriverName) }}
                </td>
                <td
                  v-if="tableData.Type == 'RACE'"
                  contenteditable="true"
                  :data-field="'points'"
                  :data-index="resultIndex"
                  class="px-6 py-4 text-center font-bold"
                  @blur="handleCellEdit"
                >
                  {{ result.customPoints || calculatePoints(resultIndex + 1) }}
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
      dragOverIndex: null,
      pendingEdits: {},
      enablePoints: false
    }
  },
  props: {
    raceData: {
      type: Object,
      default: null
    },
    currentResultId: {
      type: String,
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
    calculatePoints(position) {
      // Points system: 25, 18, 15, 12, 10, 8, 6, 4, 2, 1, then 0 for 11+
      const pointsTable = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1]

      if (position <= 10) {
        return pointsTable[position - 1]
      }
      return 0
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
    getDriverTeam(driverName) {
      if (!this.tableData.Cars) return ''

      // Find the driver in the Cars array
      const car = this.tableData.Cars.find((car) => car.Driver && car.Driver.Name === driverName)

      if (car && car.Driver && car.Driver.Team) {
        return car.Driver.Team
      }

      return ''
    },
    getDriverCar(driverName) {
      if (!this.tableData.Cars) return ''

      // Find the driver in the Cars array
      const car = this.tableData.Cars.find((car) => car.Driver && car.Driver.Name === driverName)

      if (car && car.Model) {
        // Format the car model name to be more readable
        return this.formatCarName(car.Model)
      }

      return ''
    },
    formatCarName(model) {
      // Remove common mod prefixes dynamically and format car names
      let formatted = model
        // Remove common prefixes (rss, gtm, ks, etc.) followed by underscore
        .replace(/^(rss|gtm|ks|ac|mod)_/gi, '')
        // Replace remaining underscores with spaces
        .replace(/_/g, ' ')
        // Trim any extra spaces
        .trim()

      // Capitalize each word
      return formatted
        .split(' ')
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
        .join(' ')
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
    getNationCode(countryName) {
      // Reverse map: country name to nation code
      const nationCodeMap = {
        Guyana: 'GUY',
        Jamaica: 'JAM',
        'Trinidad & Tobago': 'TTO',
        Barbados: 'BRB',
        Bahamas: 'BHS',
        'Antigua and Barbuda': 'ATG',
        Dominica: 'DMA',
        Grenada: 'GRD',
        'St. Kitts and Nevis': 'KNA',
        'Saint Lucia': 'LCA',
        'St. Vincent and the Grenadines': 'VCT',
        Belize: 'BLZ',
        Suriname: 'SUR',
        Haiti: 'HTI',
        Cuba: 'CUB',
        Canada: 'CAN',
        USA: 'USA',
        Montserrat: 'MSR',
        Anguilla: 'AIA',
        'British Virgin Islands': 'VGB',
        'Cayman Islands': 'CYM',
        'Turks and Caicos Islands': 'TCA',
        Bermuda: 'BMU',
        Denmark: 'DNK',
        'South Africa': 'ZAF'
      }

      return nationCodeMap[countryName] || ''
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
    handleCellEdit(event) {
      const index = parseInt(event.target.dataset.index)
      const field = event.target.dataset.field
      const value = event.target.textContent.trim()

      if (!this.pendingEdits[index]) {
        this.pendingEdits[index] = {}
      }
      this.pendingEdits[index][field] = value
    },
    handleCountryChange(event) {
      const index = parseInt(event.target.dataset.index)
      const value = event.target.value

      if (!this.pendingEdits[index]) {
        this.pendingEdits[index] = {}
      }
      this.pendingEdits[index]['country'] = value
    },
    saveChanges() {
      // Apply all pending edits to the data structure
      Object.keys(this.pendingEdits).forEach((index) => {
        const edits = this.pendingEdits[index]
        const i = parseInt(index)

        if (this.tableData.Result[i]) {
          const originalDriverName = this.tableData.Result[i].DriverName

          // Update driver name if changed
          if (edits.name) {
            this.tableData.Result[i].DriverName = edits.name

            // Update in Cars array
            if (this.tableData.Cars) {
              const carIndex = this.tableData.Cars.findIndex(
                (car) => car.Driver && car.Driver.Name === originalDriverName
              )
              if (carIndex !== -1) {
                this.tableData.Cars[carIndex].Driver.Name = edits.name
              }
            }

            // Update in Laps array
            if (this.tableData.Laps) {
              this.tableData.Laps.forEach((lap) => {
                if (lap.DriverName === originalDriverName) {
                  lap.DriverName = edits.name
                }
              })
            }
          }

          // Update team if changed
          if (edits.team) {
            const currentDriverName = edits.name || this.tableData.Result[i].DriverName

            if (this.tableData.Cars) {
              const carIndex = this.tableData.Cars.findIndex(
                (car) => car.Driver && car.Driver.Name === currentDriverName
              )
              if (carIndex !== -1) {
                this.tableData.Cars[carIndex].Driver.Team = edits.team
              }
            }
          }

          // Update country if changed
          if (edits.country) {
            const currentDriverName = edits.name || this.tableData.Result[i].DriverName
            const nationCode = this.getNationCode(edits.country)

            if (this.tableData.Cars) {
              const carIndex = this.tableData.Cars.findIndex(
                (car) => car.Driver && car.Driver.Name === currentDriverName
              )
              if (carIndex !== -1) {
                this.tableData.Cars[carIndex].Driver.Nation = nationCode
              }
            }
          }

          // Update car if changed
          if (edits.car) {
            const currentDriverName = edits.name || this.tableData.Result[i].DriverName

            if (this.tableData.Cars) {
              const carIndex = this.tableData.Cars.findIndex(
                (car) => car.Driver && car.Driver.Name === currentDriverName
              )
              if (carIndex !== -1) {
                this.tableData.Cars[carIndex].Model = edits.car
              }
            }
          }

          // Store custom display values for calculated fields
          if (edits.totalTime) {
            this.tableData.Result[i].customTotalTime = edits.totalTime
          }

          if (edits.bestLap) {
            this.tableData.Result[i].customBestLap = edits.bestLap
          }

          if (edits.gap) {
            this.tableData.Result[i].customGap = edits.gap
          }

          if (edits.laps) {
            this.tableData.Result[i].customLaps = edits.laps
          }

          if (edits.points) {
            this.tableData.Result[i].customPoints = edits.points
          }
        }
      })

      // Clear pending edits
      this.pendingEdits = {}

      // Save to localStorage (current working copy)
      this.saveDataToLocalStorage(this.tableData)

      // Generate suggested name based on date and type
      const date = this.formatDate(this.tableData.Date)
      const type = this.tableData.Type === 'QUALIFY' ? 'Qualifying' : 'Race'
      const suggestedName = `${type} - ${date}`

      // Emit to parent to save as a result
      this.$emit('save-result', {
        id: this.currentResultId,
        data: this.tableData,
        suggestedName: suggestedName
      })
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
      this.enablePoints = this.raceData.enablePoints || false
    }
  }
}
</script>
