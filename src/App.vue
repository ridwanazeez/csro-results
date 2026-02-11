<template>
  <div class="flex dark:bg-gray-900 w-full min-h-screen">
    <SideNav
      v-if="uploaded"
      @settings="updateResultsTable"
      @load-result="loadSavedResult"
      @delete-result="deleteSavedResult"
      @view-standings="viewStandings"
      @global-reset="globalReset"
      @save-changes="handleSaveChanges"
      @screenshot="handleScreenshot"
      @back-to-table="backToTable"
      :saved-results="savedResults"
      :current-view="currentView"
    ></SideNav>
    <div class="m-auto px-6 lg:px-8 max-w-[80%]">
      <div class="mx-auto">
        <div v-if="!uploaded">
          <img class="w-1/2 mx-auto" src="/images/csro-logo.png" alt="CSRO Logo" />
          <h1 class="mt-4 text-3xl text-center font-bold dark:text-white">
            CSRO Results Generator
          </h1>
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
        <ResultsTable
          v-if="uploaded && currentView === 'table'"
          ref="resultsTable"
          :race-data="settings"
          :current-result-id="currentResultId"
          :key="resultsTableKey"
          @save-result="saveResult"
        ></ResultsTable>
        <StandingsView
          v-if="uploaded && currentView === 'standings'"
          ref="standingsView"
          :saved-results="savedResults"
          :settings="settings"
        ></StandingsView>
      </div>
    </div>
  </div>
</template>

<script>
import { version } from '../package.json'
import ResultsTable from './components/ResultsTable.vue'
import SideNav from './components/SideNav.vue'
import StandingsView from './components/StandingsView.vue'

export default {
  components: { ResultsTable, SideNav, StandingsView },
  data() {
    return {
      jsonData: [],
      uploaded: false,
      settings: null,
      resultsTableKey: 0,
      version: version,
      savedResults: [],
      currentResultId: null,
      currentView: 'table'
    }
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
            this.currentResultId = null // New upload, not saved yet
            this.currentView = 'table'
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
      // Load saved results
      const savedResultsData = localStorage.getItem('CSRO_SAVED_RESULTS')
      if (savedResultsData) {
        this.savedResults = JSON.parse(savedResultsData)
      }
    },
    updateResultsTable(data) {
      this.settings = data
      this.resultsTableKey += 1
    },
    saveResult(resultData) {
      const resultName = prompt(
        'Enter a name for this result:',
        resultData.suggestedName || 'Result'
      )
      if (!resultName) return

      // Check if a result with this name already exists
      const existingByName = this.savedResults.find((r) => r.name === resultName)
      const existingById = this.savedResults.findIndex((r) => r.id === resultData.id)

      let resultId = resultData.id

      if (existingByName && existingByName.id !== resultData.id) {
        // Same name, different ID - overwrite the existing one
        resultId = existingByName.id
      } else if (!resultId) {
        // New result, generate new ID
        resultId = Date.now().toString()
      }

      const result = {
        id: resultId,
        name: resultName,
        data: resultData.data,
        timestamp: Date.now()
      }

      // Check if updating existing result by ID
      const existingIndex = this.savedResults.findIndex((r) => r.id === result.id)
      if (existingIndex !== -1) {
        this.savedResults[existingIndex] = result
      } else {
        this.savedResults.push(result)
      }

      // Save to localStorage
      localStorage.setItem('CSRO_SAVED_RESULTS', JSON.stringify(this.savedResults))
      this.currentResultId = result.id

      alert(`Result "${resultName}" saved successfully!`)
    },
    loadSavedResult(resultId) {
      const result = this.savedResults.find((r) => r.id === resultId)
      if (result) {
        localStorage.setItem('CSRO_RESULT', JSON.stringify(result.data))
        this.currentResultId = result.id
        this.currentView = 'table'
        this.uploaded = true
        this.resultsTableKey += 1
        window.location.reload()
      }
    },
    deleteSavedResult(resultId) {
      if (confirm('Are you sure you want to delete this result?')) {
        this.savedResults = this.savedResults.filter((r) => r.id !== resultId)
        localStorage.setItem('CSRO_SAVED_RESULTS', JSON.stringify(this.savedResults))

        // If deleting current result, clear the current data
        if (this.currentResultId === resultId) {
          this.currentResultId = null
          localStorage.removeItem('CSRO_RESULT')
          this.uploaded = false
        }

        // Force update of standings view if currently viewing it
        if (this.currentView === 'standings') {
          this.resultsTableKey += 1
        }
      }
    },
    viewStandings() {
      this.currentView = 'standings'
      this.resultsTableKey += 1
    },
    backToTable() {
      this.currentView = 'table'
      this.resultsTableKey += 1
    },
    globalReset() {
      if (
        confirm('WARNING: This will delete ALL saved results, settings, and images. Are you sure?')
      ) {
        if (confirm('This action cannot be undone. Continue?')) {
          localStorage.clear()
          window.location.reload()
        }
      }
    },
    handleSaveChanges() {
      if (this.$refs.resultsTable) {
        this.$refs.resultsTable.saveChanges()
      }
    },
    handleScreenshot() {
      if (this.currentView === 'table' && this.$refs.resultsTable) {
        this.$refs.resultsTable.captureScreenshot()
      } else if (this.currentView === 'standings' && this.$refs.standingsView) {
        this.$refs.standingsView.captureScreenshot()
      }
    }
  },
  mounted() {
    this.loadDataFromLocalStorage()
  }
}
</script>
