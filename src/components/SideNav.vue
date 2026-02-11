<template>
  <aside class="w-[300px] h-screen bg-gray-800 text-white p-4 overflow-y-auto">
    <div class="mb-4">
      <h1 class="text-2xl font-bold">Settings</h1>
    </div>
    <nav>
      <div class="mb-4">
        <label for="seriesTitle" class="block text-sm font-medium leading-6 text-white"
          >Series Title</label
        >
        <textarea
          id="seriesTitle"
          v-model="seriesTitle"
          @input="saveSettings"
          name="seriesTitle"
          class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6"
        ></textarea>
      </div>
      <div class="mb-4">
        <label for="resultsTitle" class="block text-sm font-medium leading-6 text-white"
          >Results Title</label
        >
        <input
          id="resultsTitle"
          v-model="resultsTitle"
          @input="saveSettings"
          name="resultsTitle"
          type="text"
          placeholder="e.g. Race Results, Qualifying Results"
          class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6"
        />
      </div>
      <div class="mb-4">
        <label for="seriesLogo" class="block text-sm font-medium leading-6 text-white">
          Series Logo
        </label>
        <input
          id="seriesLogo"
          name="seriesLogo"
          type="file"
          class="sr-only"
          @change="changeSeriesLogo"
        />
        <label for="seriesLogo" class="cursor-pointer">
          <span class="bg-blue-500 text-white py-2 px-4 inline-block rounded-md">Upload Image</span>
        </label>
      </div>
      <div class="mb-4">
        <label class="flex items-center cursor-pointer">
          <input
            type="checkbox"
            v-model="enablePoints"
            @change="saveSettings"
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 focus:ring-2"
          />
          <span class="ml-2 text-sm font-medium text-white">Enable Points</span>
        </label>
      </div>

      <!-- Saved Results Section -->
      <div class="mb-4 border-t border-gray-600 pt-4">
        <h2 class="text-lg font-bold mb-2">Saved Results</h2>
        <div v-if="savedResults.length === 0" class="text-sm text-gray-400">
          No saved results yet
        </div>
        <div v-else class="space-y-2">
          <div
            v-for="result in savedResults"
            :key="result.id"
            class="bg-gray-700 p-2 rounded flex justify-between items-center"
          >
            <button
              @click="$emit('load-result', result.id)"
              class="text-sm text-left flex-1 hover:text-blue-400"
            >
              {{ result.name }}
            </button>
            <button
              @click="$emit('delete-result', result.id)"
              class="text-red-400 hover:text-red-300 ml-2"
              title="Delete"
            >
              ×
            </button>
          </div>
        </div>
      </div>

      <!-- View Standings Button -->
      <div class="mb-4" v-if="enablePoints && savedResults.length > 0">
        <button
          class="rounded-md bg-purple-600 hover:bg-purple-700 p-2 text-base text-white w-full"
          @click="$emit('view-standings')"
        >
          📊 View Standings
        </button>
      </div>

      <!-- Action Buttons -->
      <div class="mb-4 border-t border-gray-600 pt-4">
        <button
          class="rounded-md bg-yellow-600 hover:bg-yellow-700 p-2 text-base text-white w-full mb-2"
          @click="clearJsonOnly()"
        >
          Upload New JSON
        </button>
        <button
          class="rounded-md bg-red-600 hover:bg-red-700 p-2 text-base text-white w-full"
          @click="$emit('global-reset')"
        >
          🔥 GLOBAL RESET
        </button>
      </div>
    </nav>
  </aside>
</template>

<script>
export default {
  props: {
    savedResults: {
      type: Array,
      default: () => []
    },
    currentView: {
      type: String,
      default: 'table'
    }
  },
  data() {
    return {
      seriesTitle: '2023 CSRO Championship',
      resultsTitle: 'Race Results',
      seriesLogo: null,
      enablePoints: false
    }
  },
  methods: {
    changeSeriesLogo(event) {
      const file = event.target.files[0]

      if (file) {
        const reader = new FileReader()

        reader.onload = (e) => {
          this.seriesLogo = e.target.result
          this.saveSettings()
        }

        reader.readAsDataURL(file)
      }
    },
    saveSettings() {
      const settings = {
        seriesTitle: this.seriesTitle,
        resultsTitle: this.resultsTitle,
        seriesLogo: this.seriesLogo,
        enablePoints: this.enablePoints
      }
      // Save to localStorage
      localStorage.setItem('CSRO_SETTINGS', JSON.stringify(settings))
      // Emit to parent
      this.$emit('settings', settings)
    },
    loadSettings() {
      const savedSettings = localStorage.getItem('CSRO_SETTINGS')
      if (savedSettings) {
        const settings = JSON.parse(savedSettings)
        this.seriesTitle = settings.seriesTitle || '2023 CSRO Championship'
        this.resultsTitle = settings.resultsTitle || 'Race Results'
        this.seriesLogo = settings.seriesLogo || null
        this.enablePoints = settings.enablePoints || false
      }
    },
    clearJsonOnly() {
      localStorage.removeItem('CSRO_RESULT')
      window.location.reload()
    }
  },
  mounted() {
    this.loadSettings()
    this.saveSettings()
  }
}
</script>
