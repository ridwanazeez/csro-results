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
        <button
          class="rounded-md bg-yellow-600 hover:bg-yellow-700 p-2 text-base text-white w-full mb-2"
          @click="clearJsonOnly()"
        >
          Upload New JSON
        </button>
        <button
          class="rounded-md bg-red-600 hover:bg-red-700 p-2 text-base text-white w-full"
          @click="clearData()"
        >
          Reset All
        </button>
      </div>
    </nav>
  </aside>
</template>

<script>
export default {
  data() {
    return {
      seriesTitle: '2023 CSRO Championship',
      resultsTitle: 'Race Results',
      seriesLogo: null
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
        seriesLogo: this.seriesLogo
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
      }
    },
    clearData() {
      localStorage.clear()
      window.location.reload()
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
