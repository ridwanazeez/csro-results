<template>
  <div class="flex justify-center py-12 px-4">
    <div
      id="standingsTable"
      class="bg-white dark:bg-gray-800 p-8 space-y-8 w-full"
      style="max-width: 900px"
    >
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
        <h1 class="text-3xl font-bold tracking-tight text-black dark:text-white">
          {{ settings?.seriesTitle || 'Championship Standings' }}
        </h1>
        <h1
          class="items-center text-2xl font-bold tracking-tight text-black dark:text-white sm:text-3xl"
        >
          {{ settings?.resultsTitle || 'Results' }}
        </h1>
      </div>

      <!-- Qualifying Results -->
      <div v-if="qualifyingResults.length > 0">
        <h2 class="text-2xl font-bold text-black dark:text-white mb-4">Qualifying Sessions</h2>
        <div v-for="(result, index) in qualifyingResults" :key="'qualify-' + index" class="mb-6">
          <h3 class="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-2">
            {{ result.name }}
          </h3>
          <div
            class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 shadow-md overflow-x-auto"
          >
            <table
              v-if="result.data && result.data.Result"
              class="w-full border-collapse bg-white dark:bg-gray-800 text-left text-sm text-gray-500 dark:text-gray-300"
            >
              <RenderTable :table="cachedTables.qualifying[index]" />
            </table>
          </div>
        </div>
      </div>

      <!-- Race Results -->
      <div v-if="raceResults.length > 0">
        <h2 class="text-2xl font-bold text-black dark:text-white mb-4">Race Results</h2>
        <div v-for="(result, index) in raceResults" :key="'race-' + index" class="mb-6">
          <h3 class="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-2">
            {{ result.name }}
          </h3>
          <div
            class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 shadow-md overflow-x-auto"
          >
            <table
              v-if="result.data && result.data.Result"
              class="w-full border-collapse bg-white dark:bg-gray-800 text-left text-sm text-gray-500 dark:text-gray-300"
            >
              <RenderTable :table="cachedTables.race[index]" />
            </table>
          </div>
        </div>
      </div>

      <!-- Driver Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black dark:text-white mb-4">Driver Standings</h2>
        <div
          class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 shadow-md overflow-x-auto"
        >
          <table
            v-if="driverStandings.length > 0"
            class="w-full border-collapse bg-white dark:bg-gray-800 text-left text-sm text-gray-500 dark:text-gray-300"
          >
            <RenderTable :table="cachedTables.driver" />
          </table>
        </div>
      </div>

      <!-- Team Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black dark:text-white mb-4">Team Standings</h2>
        <div
          class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 shadow-md overflow-x-auto"
        >
          <table
            v-if="teamStandings.length > 0"
            class="w-full border-collapse bg-white dark:bg-gray-800 text-left text-sm text-gray-500 dark:text-gray-300"
          >
            <RenderTable :table="cachedTables.team" />
          </table>
        </div>
      </div>

      <!-- Country Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black dark:text-white mb-4">Country Standings</h2>
        <div
          class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 shadow-md overflow-x-auto"
        >
          <table
            v-if="countryStandings.length > 0"
            class="w-full border-collapse bg-white dark:bg-gray-800 text-left text-sm text-gray-500 dark:text-gray-300"
          >
            <RenderTable :table="cachedTables.country" />
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { FlexRender, getCoreRowModel, useVueTable } from '@tanstack/vue-table'
import * as flags from 'country-flag-icons/string/3x2'
import html2canvas from 'html2canvas'
import { h } from 'vue'

const RenderTable = {
  props: ['table'],
  render() {
    const table = this.table
    return [
      h(
        'thead',
        { class: 'bg-gray-50 dark:bg-gray-700' },
        table.getHeaderGroups().map((headerGroup) =>
          h(
            'tr',
            { key: headerGroup.id },
            headerGroup.headers.map((header) =>
              h(
                'th',
                {
                  key: header.id,
                  class: 'px-3 py-2 font-medium text-gray-900 dark:text-white text-center'
                },
                [
                  h(FlexRender, {
                    render: header.column.columnDef.header,
                    props: header.getContext()
                  })
                ]
              )
            )
          )
        )
      ),
      h(
        'tbody',
        {
          class:
            'divide-y divide-gray-100 dark:divide-gray-700 border-t border-gray-100 dark:border-gray-700'
        },
        table.getRowModel().rows.map((row) =>
          h(
            'tr',
            {
              key: row.id,
              class: 'hover:bg-gray-50 dark:hover:bg-gray-700'
            },
            row.getVisibleCells().map((cell) =>
              h(
                'td',
                {
                  key: cell.id,
                  class: 'px-3 py-2 dark:text-gray-300'
                },
                h(FlexRender, {
                  render: cell.column.columnDef.cell,
                  props: cell.getContext()
                })
              )
            )
          )
        )
      )
    ]
  }
}

export default {
  components: {
    FlexRender,
    RenderTable
  },
  data() {
    return {
      cachedTables: {
        qualifying: [],
        race: [],
        driver: null,
        team: null,
        country: null
      }
    }
  },
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
      const driverData = {}

      this.raceResults.forEach((result) => {
        if (result.data && result.data.Result) {
          result.data.Result.forEach((driver, index) => {
            const points = driver.customPoints || this.calculatePoints(index + 1)
            const driverName = driver.DriverName

            if (!driverData[driverName]) {
              const car = result.data.Cars?.find((c) => c.Driver && c.Driver.Name === driverName)
              driverData[driverName] = {
                points: 0,
                team: car?.Driver?.Team || 'No Team',
                country: this.getNationName(car?.Driver?.Nation) || 'Unknown'
              }
            }
            driverData[driverName].points += parseInt(points) || 0
          })
        }
      })

      return Object.entries(driverData)
        .map(([name, data]) => ({
          name,
          points: data.points,
          team: data.team,
          country: data.country
        }))
        .sort((a, b) => b.points - a.points)
    },
    teamStandings() {
      const teamPoints = {}

      this.raceResults.forEach((result) => {
        if (result.data && result.data.Result && result.data.Cars) {
          result.data.Result.forEach((driver, index) => {
            const points = driver.customPoints || this.calculatePoints(index + 1)
            const driverName = driver.DriverName

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

      this.raceResults.forEach((result) => {
        if (result.data && result.data.Result && result.data.Cars) {
          result.data.Result.forEach((driver, index) => {
            const points = driver.customPoints || this.calculatePoints(index + 1)
            const driverName = driver.DriverName

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
  watch: {
    qualifyingResults: {
      handler() {
        this.cachedTables.qualifying = this.qualifyingResults.map((result) =>
          this.createQualifyingTable(result.data)
        )
      },
      immediate: true
    },
    raceResults: {
      handler() {
        this.cachedTables.race = this.raceResults.map((result) => this.createRaceTable(result.data))
      },
      immediate: true
    },
    driverStandings: {
      handler() {
        this.cachedTables.driver = this.createStandingsTable(this.driverStandings, 'driver')
      },
      immediate: true
    },
    teamStandings: {
      handler() {
        this.cachedTables.team = this.createStandingsTable(this.teamStandings, 'team')
      },
      immediate: true
    },
    countryStandings: {
      handler() {
        this.cachedTables.country = this.createStandingsTable(this.countryStandings, 'country')
      },
      immediate: true
    }
  },
  methods: {
    createQualifyingTable(data) {
      const columns = [
        {
          accessorKey: 'position',
          header: 'Pos',
          size: 40,
          cell: ({ row }) => h('span', { class: 'font-bold' }, row.index + 1)
        },
        {
          accessorKey: 'DriverName',
          header: 'Driver',
          size: 140,
          cell: ({ row, getValue }) => {
            const value = getValue()
            const flagHtml = this.getCountryFlag(this.getNationCode(data.Cars, value))
            return h('div', { class: 'flex items-center gap-2' }, [
              flagHtml
                ? h('span', {
                    innerHTML: flagHtml,
                    class: 'inline-block w-6 h-4 rounded-sm overflow-hidden flex-shrink-0'
                  })
                : null,
              h('span', value)
            ])
          }
        },
        {
          accessorKey: 'team',
          header: 'Team',
          size: 100,
          cell: ({ row }) =>
            h(
              'span',
              { class: 'text-center block' },
              this.getTeamName(data.Cars, row.original.DriverName)
            )
        },
        {
          accessorKey: 'car',
          header: 'Car',
          size: 100,
          cell: ({ row }) =>
            h(
              'span',
              { class: 'text-center block' },
              this.getCarName(data.Cars, row.original.DriverName)
            )
        },
        {
          accessorKey: 'BestLap',
          header: 'Best Lap',
          size: 85,
          cell: ({ row, getValue }) => {
            const isBest = this.isBestLapInResult(getValue(), data.Result)
            return h(
              'span',
              {
                class: `text-center block font-mono ${isBest ? 'bg-green-600 text-white' : ''}`
              },
              this.formatTime(getValue())
            )
          }
        },
        {
          accessorKey: 'laps',
          header: '# of Laps',
          size: 60,
          cell: ({ row }) =>
            h(
              'span',
              { class: 'text-center block' },
              this.calculateTotalLaps(data.Laps, row.original.DriverName)
            )
        }
      ]

      return useVueTable({
        data: data.Result || [],
        columns,
        getCoreRowModel: getCoreRowModel()
      })
    },
    createRaceTable(data) {
      const columns = [
        {
          accessorKey: 'position',
          header: 'Pos',
          size: 40,
          cell: ({ row }) => h('span', { class: 'font-bold' }, row.index + 1)
        },
        {
          accessorKey: 'DriverName',
          header: 'Driver',
          size: 140,
          cell: ({ row, getValue }) => {
            const value = getValue()
            const flagHtml = this.getCountryFlag(this.getNationCode(data.Cars, value))
            return h('div', { class: 'flex items-center gap-2' }, [
              flagHtml
                ? h('span', {
                    innerHTML: flagHtml,
                    class: 'inline-block w-6 h-4 rounded-sm overflow-hidden flex-shrink-0'
                  })
                : null,
              h('span', value)
            ])
          }
        },
        {
          accessorKey: 'team',
          header: 'Team',
          size: 120,
          cell: ({ row }) =>
            h(
              'span',
              { class: 'text-center block' },
              this.getTeamName(data.Cars, row.original.DriverName)
            )
        },
        {
          accessorKey: 'car',
          header: 'Car',
          size: 120,
          cell: ({ row }) =>
            h(
              'span',
              { class: 'text-center block' },
              this.getCarName(data.Cars, row.original.DriverName)
            )
        },
        {
          accessorKey: 'TotalTime',
          header: 'Total Time',
          size: 85,
          cell: ({ getValue }) =>
            h('span', { class: 'text-center block font-mono' }, this.formatTime(getValue()))
        },
        {
          accessorKey: 'BestLap',
          header: 'Best Lap',
          size: 85,
          cell: ({ row, getValue }) => {
            const isBest = this.isBestLapInResult(getValue(), data.Result)
            return h(
              'span',
              {
                class: `text-center block font-mono ${isBest ? 'bg-green-600 text-white' : ''}`
              },
              this.formatTime(getValue())
            )
          }
        },
        {
          accessorKey: 'laps',
          header: '# of Laps',
          size: 60,
          cell: ({ row }) =>
            h(
              'span',
              { class: 'text-center block' },
              this.calculateTotalLaps(data.Laps, row.original.DriverName)
            )
        },
        {
          accessorKey: 'points',
          header: 'Points',
          size: 55,
          cell: ({ row }) => {
            const points = row.original.customPoints || this.calculatePoints(row.index + 1)
            return h('span', { class: 'text-center block font-bold' }, points)
          }
        }
      ]

      return useVueTable({
        data: data.Result || [],
        columns,
        getCoreRowModel: getCoreRowModel()
      })
    },
    createStandingsTable(data, type) {
      const columns = []

      columns.push({
        accessorKey: 'position',
        header: '#',
        size: 40,
        cell: ({ row }) => h('span', { class: 'font-bold' }, row.index + 1)
      })

      if (type === 'driver' || type === 'country') {
        columns.push({
          accessorKey: 'name',
          header: type === 'driver' ? 'Driver' : 'Country',
          size: 150,
          cell: ({ row }) => {
            const item = row.original
            const name = item.name
            const countryName = type === 'driver' ? item.country : name
            const nationCode = this.getNationCodeFromName(countryName)
            const flagHtml = this.getCountryFlag(nationCode)
            return h('div', { class: 'flex items-center gap-2' }, [
              flagHtml
                ? h('span', {
                    innerHTML: flagHtml,
                    class: 'inline-block w-6 h-4 rounded-sm overflow-hidden flex-shrink-0'
                  })
                : null,
              h('span', name)
            ])
          }
        })
      } else {
        columns.push({
          accessorKey: 'name',
          header: 'Team',
          size: 150
        })
      }

      if (type === 'driver') {
        columns.push({
          accessorKey: 'team',
          header: 'Team',
          size: 100
        })
      }

      columns.push({
        accessorKey: 'points',
        header: 'Points',
        size: 55,
        cell: ({ getValue }) => h('span', { class: 'text-center block font-bold' }, getValue())
      })

      return useVueTable({
        data: data || [],
        columns,
        getCoreRowModel: getCoreRowModel()
      })
    },
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
    getCountryName(cars, driverName) {
      if (!cars) return ''
      const car = cars.find((c) => c.Driver && c.Driver.Name === driverName)
      const nationCode = car?.Driver?.Nation
      return this.getNationName(nationCode) || ''
    },
    getCarName(cars, driverName) {
      if (!cars) return ''
      const car = cars.find((c) => c.Driver && c.Driver.Name === driverName)
      if (car && car.Model) {
        return this.formatCarName(car.Model)
      }
      return ''
    },
    formatCarName(model) {
      let formatted = model
        .replace(/^(rss|gtm|ks|ac|mod)_/gi, '')
        .replace(/_/g, ' ')
        .trim()

      return formatted
        .split(' ')
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
        .join(' ')
    },
    calculateTotalLaps(laps, driverName) {
      if (!laps) return 0
      let totalLaps = 0
      for (let i = 0; i < laps.length; i++) {
        if (laps[i].DriverName === driverName) {
          totalLaps++
        }
      }
      return totalLaps
    },
    isBestLapInResult(currentBestLap, results) {
      if (!results || results.length === 0) return false
      const allBestLaps = results.map((result) => result.BestLap)
      const smallestBestLap = Math.min(...allBestLaps)
      return currentBestLap === smallestBestLap
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
    getNationCode(cars, driverName) {
      if (!cars) return ''
      const car = cars.find((c) => c.Driver && c.Driver.Name === driverName)
      return car?.Driver?.Nation || ''
    },
    getNationCodeFromName(countryName) {
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
    getCountryFlag(nationCode) {
      const isoCodeMap = {
        GUY: 'GY',
        JAM: 'JM',
        TTO: 'TT',
        BRB: 'BB',
        BHS: 'BS',
        ATG: 'AG',
        DMA: 'DM',
        GRD: 'GD',
        KNA: 'KN',
        LCA: 'LC',
        VCT: 'VC',
        BLZ: 'BZ',
        SUR: 'SR',
        HTI: 'HT',
        CUB: 'CU',
        CAN: 'CA',
        USA: 'US',
        MSR: 'MS',
        AIA: 'AI',
        VGB: 'VG',
        CYM: 'KY',
        TCA: 'TC',
        BMU: 'BM',
        DNK: 'DK',
        ZAF: 'ZA'
      }

      const isoCode = isoCodeMap[nationCode]
      if (!isoCode) return ''

      return flags[isoCode] || ''
    },
    async captureScreenshot() {
      const element = document.getElementById('standingsTable')
      if (!element) {
        console.error('Standings table element not found')
        return
      }

      try {
        const htmlElement = document.documentElement
        const isDarkMode = htmlElement.classList.contains('dark')

        const canvas = await html2canvas(element, {
          backgroundColor: isDarkMode ? '#111827' : '#ffffff',
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
