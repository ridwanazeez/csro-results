<template>
  <div class="py-12">
    <div id="standingsTable" class="bg-white p-8 space-y-8">
      <!-- Header -->
      <div class="flex align-middle items-center mb-5">
        <img class="w-1/4 mx-auto" src="/images/csro-logo.png" alt="CSRO Logo" />
        <img
          v-if="settings && settings.seriesLogo"
          class="w-1/4 mx-auto"
          :src="settings.seriesLogo"
          alt="CSRO Racing Series Logo"
        />
        <img v-else class="w-1/4 mx-auto" src="/images/csro-logo.png" alt="CSRO Logo" />
      </div>

      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold tracking-tight text-black">
          {{ settings?.seriesTitle || 'Championship Standings' }}
        </h1>
        <h1 class="items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
          {{ settings?.resultsTitle || 'Results' }}
        </h1>
      </div>

      <!-- Qualifying Results -->
      <div v-if="qualifyingResults.length > 0">
        <h2 class="text-2xl font-bold text-black mb-4">Qualifying Sessions</h2>
        <div v-for="(result, index) in qualifyingResults" :key="'qualify-' + index" class="mb-6">
          <h3 class="text-lg font-semibold text-gray-700 mb-2">{{ result.name }}</h3>
          <div class="overflow-hidden rounded-lg border border-gray-200 shadow-md">
            <table
              class="w-full border-collapse bg-white text-left text-sm text-gray-500 table-auto"
            >
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-4 font-medium text-gray-900 text-center">Pos</th>
                  <th class="px-6 py-4 font-medium text-gray-900">Driver</th>
                  <th class="px-6 py-4 font-medium text-gray-900">Team</th>
                  <th class="px-6 py-4 font-medium text-gray-900 text-center">Best Lap</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-100 border-t border-gray-100">
                <tr v-for="(driver, idx) in result.data.Result" :key="idx" class="hover:bg-gray-50">
                  <th class="px-6 py-4 font-bold text-center">{{ idx + 1 }}</th>
                  <td class="px-6 py-4 font-normal text-gray-900">{{ driver.DriverName }}</td>
                  <td class="px-6 py-4 font-normal text-gray-900">
                    {{ getTeamName(result.data.Cars, driver.DriverName) }}
                  </td>
                  <td class="px-6 py-4 text-center font-mono">
                    {{ formatTime(driver.BestLap) }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Race Results -->
      <div v-if="raceResults.length > 0">
        <h2 class="text-2xl font-bold text-black mb-4">Race Results</h2>
        <div v-for="(result, index) in raceResults" :key="'race-' + index" class="mb-6">
          <h3 class="text-lg font-semibold text-gray-700 mb-2">{{ result.name }}</h3>
          <div class="overflow-hidden rounded-lg border border-gray-200 shadow-md">
            <table
              class="w-full border-collapse bg-white text-left text-sm text-gray-500 table-auto"
            >
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-4 font-medium text-gray-900 text-center">Pos</th>
                  <th class="px-6 py-4 font-medium text-gray-900">Driver</th>
                  <th class="px-6 py-4 font-medium text-gray-900">Team</th>
                  <th class="px-6 py-4 font-medium text-gray-900 text-center">Total Time</th>
                  <th class="px-6 py-4 font-medium text-gray-900 text-center">Points</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-100 border-t border-gray-100">
                <tr v-for="(driver, idx) in result.data.Result" :key="idx" class="hover:bg-gray-50">
                  <th class="px-6 py-4 font-bold text-center">{{ idx + 1 }}</th>
                  <td class="px-6 py-4 font-normal text-gray-900">{{ driver.DriverName }}</td>
                  <td class="px-6 py-4 font-normal text-gray-900">
                    {{ getTeamName(result.data.Cars, driver.DriverName) }}
                  </td>
                  <td class="px-6 py-4 text-center font-mono">
                    {{ formatTime(driver.TotalTime) }}
                  </td>
                  <td class="px-6 py-4 text-center font-bold">
                    {{ driver.customPoints || calculatePoints(idx + 1) }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Driver Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black mb-4">Driver Standings</h2>
        <div class="overflow-hidden rounded-lg border border-gray-200 shadow-md">
          <table class="w-full border-collapse bg-white text-left text-sm text-gray-500 table-auto">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-4 font-medium text-gray-900 text-center">#</th>
                <th class="px-6 py-4 font-medium text-gray-900">Driver</th>
                <th class="px-6 py-4 font-medium text-gray-900 text-center">Points</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 border-t border-gray-100">
              <tr v-for="(driver, index) in driverStandings" :key="index" class="hover:bg-gray-50">
                <th class="px-6 py-4 font-bold text-center">{{ index + 1 }}</th>
                <td class="px-6 py-4 font-normal text-gray-900">{{ driver.name }}</td>
                <td class="px-6 py-4 text-center font-bold">{{ driver.points }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Team Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black mb-4">Team Standings</h2>
        <div class="overflow-hidden rounded-lg border border-gray-200 shadow-md">
          <table class="w-full border-collapse bg-white text-left text-sm text-gray-500 table-auto">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-4 font-medium text-gray-900 text-center">#</th>
                <th class="px-6 py-4 font-medium text-gray-900">Team</th>
                <th class="px-6 py-4 font-medium text-gray-900 text-center">Points</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 border-t border-gray-100">
              <tr v-for="(team, index) in teamStandings" :key="index" class="hover:bg-gray-50">
                <th class="px-6 py-4 font-bold text-center">{{ index + 1 }}</th>
                <td class="px-6 py-4 font-normal text-gray-900">{{ team.name }}</td>
                <td class="px-6 py-4 text-center font-bold">{{ team.points }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Country Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black mb-4">Country Standings</h2>
        <div class="overflow-hidden rounded-lg border border-gray-200 shadow-md">
          <table class="w-full border-collapse bg-white text-left text-sm text-gray-500 table-auto">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-4 font-medium text-gray-900 text-center">#</th>
                <th class="px-6 py-4 font-medium text-gray-900">Country</th>
                <th class="px-6 py-4 font-medium text-gray-900 text-center">Points</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 border-t border-gray-100">
              <tr
                v-for="(country, index) in countryStandings"
                :key="index"
                class="hover:bg-gray-50"
              >
                <th class="px-6 py-4 font-bold text-center">{{ index + 1 }}</th>
                <td class="px-6 py-4 font-normal text-gray-900">{{ country.name }}</td>
                <td class="px-6 py-4 text-center font-bold">{{ country.points }}</td>
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
  props: {
    savedResults: {
      type: Array,
      required: true
    },
    settings: {
      type: Object,
      default: null
    }
  },
  computed: {
    qualifyingResults() {
      return this.savedResults.filter((result) => result.data && result.data.Type === 'QUALIFY')
    },
    raceResults() {
      return this.savedResults.filter((result) => result.data && result.data.Type === 'RACE')
    },
    driverStandings() {
      const driverPoints = {}

      // Only count points from RACE type results
      this.raceResults.forEach((result) => {
        if (result.data && result.data.Result) {
          result.data.Result.forEach((driver, index) => {
            const points = driver.customPoints || this.calculatePoints(index + 1)
            const driverName = driver.DriverName

            if (!driverPoints[driverName]) {
              driverPoints[driverName] = 0
            }
            driverPoints[driverName] += parseInt(points) || 0
          })
        }
      })

      return Object.entries(driverPoints)
        .map(([name, points]) => ({ name, points }))
        .sort((a, b) => b.points - a.points)
    },
    teamStandings() {
      const teamPoints = {}

      // Only count points from RACE type results
      this.raceResults.forEach((result) => {
        if (result.data && result.data.Result && result.data.Cars) {
          result.data.Result.forEach((driver, index) => {
            const points = driver.customPoints || this.calculatePoints(index + 1)
            const driverName = driver.DriverName

            // Find team from Cars array
            const car = result.data.Cars.find((c) => c.Driver && c.Driver.Name === driverName)
            const teamName = car?.Driver?.Team || 'No Team'

            if (teamName && teamName !== 'No Team' && teamName.trim() !== '') {
              if (!teamPoints[teamName]) {
                teamPoints[teamName] = 0
              }
              teamPoints[teamName] += parseInt(points) || 0
            }
          })
        }
      })

      return Object.entries(teamPoints)
        .map(([name, points]) => ({ name, points }))
        .sort((a, b) => b.points - a.points)
    },
    countryStandings() {
      const countryPoints = {}

      // Only count points from RACE type results
      this.raceResults.forEach((result) => {
        if (result.data && result.data.Result && result.data.Cars) {
          result.data.Result.forEach((driver, index) => {
            const points = driver.customPoints || this.calculatePoints(index + 1)
            const driverName = driver.DriverName

            // Find country from Cars array
            const car = result.data.Cars.find((c) => c.Driver && c.Driver.Name === driverName)
            const countryCode = car?.Driver?.Nation
            const countryName = this.getNationName(countryCode) || 'Unknown'

            if (countryName && countryName !== 'Unknown' && countryName.trim() !== '') {
              if (!countryPoints[countryName]) {
                countryPoints[countryName] = 0
              }
              countryPoints[countryName] += parseInt(points) || 0
            }
          })
        }
      })

      return Object.entries(countryPoints)
        .map(([name, points]) => ({ name, points }))
        .sort((a, b) => b.points - a.points)
    }
  },
  methods: {
    calculatePoints(position) {
      const pointsTable = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1]
      if (position <= 10) {
        return pointsTable[position - 1]
      }
      return 0
    },
    formatTime(milliseconds) {
      if (!milliseconds || milliseconds === 0) return '-'

      const totalSeconds = Math.floor(milliseconds / 1000)
      const minutes = Math.floor(totalSeconds / 60)
      const seconds = totalSeconds % 60
      const ms = milliseconds % 1000

      const secondsStr = seconds < 10 ? `0${seconds}` : seconds
      const msStr = ms < 100 ? (ms < 10 ? `00${ms}` : `0${ms}`) : ms

      return `${minutes}:${secondsStr}.${msStr}`
    },
    getTeamName(cars, driverName) {
      if (!cars) return 'No Team'
      const car = cars.find((c) => c.Driver && c.Driver.Name === driverName)
      return car?.Driver?.Team || 'No Team'
    },
    getNationName(nationCode) {
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
        ZAF: 'South Africa',
        SAI: 'Saint Lucia'
      }
      return nationMap[nationCode] || ''
    },
    async captureScreenshot() {
      const element = document.getElementById('standingsTable')
      if (!element) {
        console.error('Standings table element not found')
        return
      }

      try {
        const canvas = await html2canvas(element, {
          backgroundColor: '#ffffff',
          scale: 2,
          logging: false,
          useCORS: true
        })

        canvas.toBlob((blob) => {
          const url = URL.createObjectURL(blob)
          const link = document.createElement('a')
          const date = new Date().toISOString().split('T')[0]
          link.download = `csro-standings-${date}.png`
          link.href = url
          link.click()
          URL.revokeObjectURL(url)
        })
      } catch (error) {
        console.error('Error capturing screenshot:', error)
      }
    }
  }
}
</script>
