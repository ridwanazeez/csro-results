<template>
  <div class="flex dark:bg-gray-900 w-full sm:h-screen">
    <SideNav v-if="uploaded" @settings="updateResultsTable"></SideNav>
    <div class="m-auto px-6 lg:px-8 max-w-[80%]">
      <div class="mx-auto">
        <div v-if="!uploaded">
          <img class="w-1/2 mx-auto" src="/images/csro-logo.png" alt="CSRO Logo" />
          <h1 class="mt-4 text-3xl text-center font-bold">CSRO Results Generator</h1>
          <p class="text-center text-sm dark:text-white">
            v{{ version }} | Last updated: 11/02/2026
          </p>
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
        <!-- <div v-if="uploaded">
          <h2 class="text-xl font-semibold mt-4">Uploaded Data:</h2>
          <pre>{{ output }}</pre>
        </div> -->
        <ResultsTable v-if="uploaded" :race-data="settings" :key="resultsTableKey"></ResultsTable>
      </div>
    </div>
  </div>
</template>

<script>
import { version } from '../package.json'
import ResultsTable from './components/ResultsTable.vue'
import SideNav from './components/SideNav.vue'

export default {
  components: { ResultsTable, SideNav },
  data() {
    return { jsonData: [], uploaded: false, settings: null, resultsTableKey: 0, version: version }
  },
  methods: {
    handleFileUpload(event) {
      const file = event.target.files[0]

      if (file) {
        const reader = new FileReader()

        reader.onload = () => {
          try {
            const fileData = JSON.parse(reader.result)
            this.jsonData = fileData
            this.saveDataToLocalStorage(this.jsonData)
            this.uploaded = true
          } catch (error) {
            console.error('Error parsing JSON:', error)
          }
        }
        reader.readAsText(file)
      }
    },
    saveDataToLocalStorage(data) {
      const jsonData = JSON.stringify(data)
      localStorage.setItem('CSRO_RESULT', jsonData)
    },
    loadDataFromLocalStorage() {
      const jsonData = localStorage.getItem('CSRO_RESULT')
      if (jsonData) {
        this.uploaded = true
      }
    },
    updateResultsTable(data) {
      this.settings = data
      this.resultsTableKey += 1
    }
  },
  mounted() {
    this.loadDataFromLocalStorage()
  }
}
</script>
