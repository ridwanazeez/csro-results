<template>
  <div class="flex justify-center py-12 px-4">
    <div
      id="standingsTable"
      class="bg-white dark:bg-gray-800 px-8 pt-12 pb-8 space-y-8 w-full"
      style="max-width: 900px"
    >
      <!-- Header -->
      <div class="flex items-center justify-center gap-8 mb-5">
        <img class="w-1/4" :src="(settings && settings.mainLogo) || defaultLogo" alt="CSRO Logo" />
        <img
          v-if="settings && settings.seriesLogo"
          class="w-1/4"
          :src="settings.seriesLogo"
          alt="CSRO Racing Series Logo"
        />
      </div>

      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold tracking-tight text-black dark:text-white">
          {{ settings?.seriesTitle || 'Championship Standings' }}
        </h1>
        <h1
          class="items-center text-2xl font-bold tracking-tight text-black dark:text-white sm:text-3xl"
        >
          {{ settings?.resultsTitle || 'Standings' }}
        </h1>
      </div>

      <!-- Driver Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black dark:text-white mb-4">Driver Standings</h2>
        <div
          class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 shadow-md overflow-x-auto"
        >
          <table
            v-if="driverStandings.length > 0"
            class="w-full border-collapse bg-white dark:bg-gray-800 text-left text-sm text-gray-700 dark:text-gray-300"
          >
            <RenderTable :table="cachedTables.driver" :remove="(row) => hideRow('driver', row)" />
          </table>
        </div>
        <button
          v-if="hiddenCount('driver')"
          data-html2canvas-ignore
          @click="restoreRows('driver')"
          class="mt-2 text-sm text-blue-600 hover:underline dark:text-blue-400"
        >
          Restore {{ hiddenCount('driver') }} removed driver(s)
        </button>
      </div>

      <!-- Team Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black dark:text-white mb-4">Team Standings</h2>
        <div
          class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 shadow-md overflow-x-auto"
        >
          <table
            v-if="teamStandings.length > 0"
            class="w-full border-collapse bg-white dark:bg-gray-800 text-left text-sm text-gray-700 dark:text-gray-300"
          >
            <RenderTable :table="cachedTables.team" :remove="(row) => hideRow('team', row)" />
          </table>
        </div>
        <button
          v-if="hiddenCount('team')"
          data-html2canvas-ignore
          @click="restoreRows('team')"
          class="mt-2 text-sm text-blue-600 hover:underline dark:text-blue-400"
        >
          Restore {{ hiddenCount('team') }} removed team(s)
        </button>
      </div>

      <!-- Country Standings -->
      <div>
        <h2 class="text-2xl font-bold text-black dark:text-white mb-4">Country Standings</h2>
        <div
          class="overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 shadow-md overflow-x-auto"
        >
          <table
            v-if="countryStandings.length > 0"
            class="w-full border-collapse bg-white dark:bg-gray-800 text-left text-sm text-gray-700 dark:text-gray-300"
          >
            <RenderTable :table="cachedTables.country" :remove="(row) => hideRow('country', row)" />
          </table>
        </div>
        <button
          v-if="hiddenCount('country')"
          data-html2canvas-ignore
          @click="restoreRows('country')"
          class="mt-2 text-sm text-blue-600 hover:underline dark:text-blue-400"
        >
          Restore {{ hiddenCount('country') }} removed country(s)
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { FlexRender, useTable } from '@tanstack/vue-table'
import * as flags from 'country-flag-icons/string/3x2'
import { h } from 'vue'
import { captureElement } from '@/screenshot'
import { hasTime } from '@/time'

// Decimal points (20.5) sum with float noise; keep two places
const round2 = (n) => Math.round(n * 100) / 100

const RenderTable = {
  // remove(row): when given, each row gets a remove button (left out of screenshots)
  props: ['table', 'remove'],
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
            headerGroup.headers
              .map((header) =>
                h(
                  'th',
                  {
                    key: header.id,
                    class:
                      'px-3 py-2 font-medium text-gray-900 dark:text-white text-center whitespace-nowrap'
                  },
                  [
                    h(FlexRender, {
                      render: header.column.columnDef.header,
                      props: header.getContext()
                    })
                  ]
                )
              )
              .concat(
                this.remove
                  ? h(
                      'th',
                      { 'data-html2canvas-ignore': '' },
                      h('span', { class: 'sr-only' }, 'Remove')
                    )
                  : []
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
              class: 'group/row hover:bg-gray-50 dark:hover:bg-gray-700'
            },
            row
              .getAllCells()
              .map((cell) =>
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
              .concat(
                this.remove
                  ? h(
                      'td',
                      { 'data-html2canvas-ignore': '' },
                      h(
                        'button',
                        {
                          onClick: () => this.remove(row.original),
                          title: 'Remove row',
                          'aria-label': `Remove ${row.original.name}`,
                          class:
                            'opacity-0 group-hover/row:opacity-100 focus:opacity-100 px-2 text-lg leading-none text-gray-400 hover:text-red-600 dark:hover:text-red-400'
                        },
                        '×'
                      )
                    )
                  : []
              )
          )
        )
      )
    ]
  }
}

export default {
  components: {
    RenderTable
  },
  data() {
    return {
      defaultLogo: import.meta.env.BASE_URL + 'images/csro-logo.png',
      // Manual corrections stored as deltas ("type:name" -> points) so later races still add on top
      pointAdjustments: this.load('CSRO_POINT_ADJUSTMENTS', {}),
      // Rows removed from the standings tables ("type:name")
      hiddenRows: this.load('CSRO_HIDDEN_STANDINGS', []),
      cachedTables: {
        qualifying: [],
        race: [],
        driver: null,
        team: null,
        country: null
      }
    }
  },
  inject: ['persist'],
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
            driverData[driverName].points += Number(points) || 0
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
        .map((row) => this.applyAdjustment(row, 'driver'))
        .filter((row) => !this.hiddenRows.includes(`driver:${row.name}`))
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
              teamPoints[teamName] += Number(points) || 0
            }
          })
        }
      })

      return Object.entries(teamPoints)
        .map(([name, points]) => ({ name, points }))
        .map((row) => this.applyAdjustment(row, 'team'))
        .filter((row) => !this.hiddenRows.includes(`team:${row.name}`))
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
              countryPoints[countryName] += Number(points) || 0
            }
          })
        }
      })

      return Object.entries(countryPoints)
        .map(([name, points]) => ({ name, points }))
        .map((row) => this.applyAdjustment(row, 'country'))
        .filter((row) => !this.hiddenRows.includes(`country:${row.name}`))
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
          cell: ({ getValue }) => {
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
          cell: ({ getValue }) => {
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

      return useTable({
        data: data.Result || [],
        columns
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
          cell: ({ getValue }) => {
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
          cell: ({ getValue }) => {
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

      return useTable({
        data: data.Result || [],
        columns
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
        cell: ({ row }) =>
          h(
            'span',
            {
              key: `${row.original.name}:${row.original.points}`,
              contenteditable: 'true',
              title: `Calculated: ${row.original.basePoints}. Clear to reset.`,
              onBlur: (event) => this.editPoints(type, row.original, event),
              onKeydown: (event) =>
                event.key === 'Enter' && (event.preventDefault(), event.target.blur()),
              class: 'text-center block font-bold'
            },
            row.original.points
          )
      })

      return useTable({
        data: data || [],
        columns
      })
    },
    load(key, fallback) {
      try {
        return JSON.parse(localStorage.getItem(key)) || fallback
      } catch {
        return fallback
      }
    },
    hiddenCount(type) {
      return this.hiddenRows.filter((key) => key.startsWith(`${type}:`)).length
    },
    hideRow(type, row) {
      this.saveHidden([...this.hiddenRows, `${type}:${row.name}`])
    },
    restoreRows(type) {
      this.saveHidden(this.hiddenRows.filter((key) => !key.startsWith(`${type}:`)))
    },
    saveHidden(next) {
      if (this.persist('CSRO_HIDDEN_STANDINGS', JSON.stringify(next))) this.hiddenRows = next
    },
    applyAdjustment(row, type) {
      const adjustment = this.pointAdjustments[`${type}:${row.name}`] || 0
      const basePoints = round2(row.points)
      return { ...row, basePoints, points: round2(basePoints + adjustment) }
    },
    editPoints(type, row, event) {
      const key = `${type}:${row.name}`
      const previous = { ...this.pointAdjustments }
      const text = event.target.textContent.trim()
      const value = Number(text)

      if (text === '') {
        delete this.pointAdjustments[key]
      } else if (isNaN(value)) {
        event.target.textContent = row.points
        return
      } else if (value === row.basePoints) {
        delete this.pointAdjustments[key]
      } else {
        this.pointAdjustments[key] = round2(value - row.basePoints)
      }
      // An unsaved edit must not stay on screen looking saved
      if (!this.persist('CSRO_POINT_ADJUSTMENTS', JSON.stringify(this.pointAdjustments))) {
        this.pointAdjustments = previous
      }
      // Clearing to the calculated total may not change `points`, so restore the text directly
      event.target.textContent = round2(row.basePoints + (this.pointAdjustments[key] || 0))
    },
    calculatePoints(position) {
      const pointsTable = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1]
      if (position <= 10) {
        return pointsTable[position - 1]
      }
      return 0
    },
    formatTime(milliseconds) {
      // Covers 0/missing and AC's 999999999 "no lap set" sentinel
      if (!hasTime(milliseconds)) return '-'

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
      // Drivers who never set a lap can't hold the fastest one
      const allBestLaps = results.map((r) => r.BestLap).filter(hasTime)
      if (!allBestLaps.length || !hasTime(currentBestLap)) return false
      return currentBestLap === Math.min(...allBestLaps)
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
      await captureElement('standingsTable', 'csro-standings').catch(() => {})
    }
  }
}
</script>
