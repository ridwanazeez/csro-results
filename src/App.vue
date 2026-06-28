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
            v{{ version }} | Last updated: 28/06/2026
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

    <!-- Name & Save Result Modal (replaces native prompt, which browsers can block) -->
    <div
      v-if="saveModal.open"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="cancelSaveResult"
    >
      <div class="bg-white dark:bg-gray-800 rounded-lg p-6 max-w-md w-full mx-4 shadow-xl">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-bold text-gray-900 dark:text-white">Save result</h3>
          <button
            @click="cancelSaveResult"
            class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            aria-label="Close"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
        <div>
          <label
            for="resultName"
            class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1"
          >
            Result name
          </label>
          <input
            id="resultName"
            ref="saveNameInput"
            v-model="saveModal.name"
            type="text"
            placeholder="e.g. Round #1 Race"
            class="w-full rounded-md border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-blue-500 focus:ring-blue-500"
            @keydown.enter.prevent="confirmSaveResult"
            @keydown.esc.prevent="cancelSaveResult"
          />
          <p v-if="saveModalDuplicate" class="mt-2 text-sm text-amber-600 dark:text-amber-400">
            A result named “{{ saveModal.name.trim() }}” already exists — saving will overwrite it.
          </p>
        </div>
        <div class="flex gap-3 mt-6">
          <button
            @click="cancelSaveResult"
            class="flex-1 px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-md hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
          >
            Cancel
          </button>
          <button
            @click="confirmSaveResult"
            :disabled="!saveModal.name.trim()"
            class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Save result
          </button>
        </div>
      </div>
    </div>

    <!-- Confirm Modal (replaces native confirm, which browsers can block) -->
    <div
      v-if="confirmDialog.open"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="closeConfirmDialog"
    >
      <div
        ref="confirmCard"
        tabindex="-1"
        class="bg-white dark:bg-gray-800 rounded-lg p-6 max-w-md w-full mx-4 shadow-xl focus:outline-none"
        @keydown.esc.prevent="closeConfirmDialog"
      >
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-bold text-gray-900 dark:text-white">{{ confirmDialog.title }}</h3>
          <button
            @click="closeConfirmDialog"
            class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            aria-label="Close"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
        <p class="text-sm text-gray-600 dark:text-gray-300">{{ confirmDialog.message }}</p>
        <div class="flex gap-3 mt-6">
          <button
            @click="closeConfirmDialog"
            class="flex-1 px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-md hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
          >
            Cancel
          </button>
          <button
            @click="confirmDialogProceed"
            :class="[
              'flex-1 px-4 py-2 text-white rounded-md transition-colors',
              confirmDialog.danger ? 'bg-red-600 hover:bg-red-700' : 'bg-blue-600 hover:bg-blue-700'
            ]"
          >
            {{ confirmDialog.confirmLabel }}
          </button>
        </div>
      </div>
    </div>

    <!-- Transient confirmation (replaces native alert) -->
    <div
      v-if="toast"
      class="fixed bottom-6 right-6 z-50 rounded-md bg-gray-900 dark:bg-gray-700 text-white px-4 py-3 shadow-xl text-sm"
      role="status"
    >
      {{ toast }}
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
      currentView: 'table',
      saveModal: { open: false, name: '', pending: null },
      confirmDialog: {
        open: false,
        title: '',
        message: '',
        confirmLabel: 'Confirm',
        danger: false,
        onConfirm: null
      },
      toast: '',
      toastTimer: null
    }
  },
  computed: {
    saveModalDuplicate() {
      const name = this.saveModal.name.trim()
      if (!name) return false
      return this.savedResults.some(
        (r) => r.name === name && r.id !== (this.saveModal.pending && this.saveModal.pending.id)
      )
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
            // Strip the heavy fields the app never reads before anything touches
            // storage, so a single upload can't blow the ~5 MB localStorage cap.
            this.jsonData = this.trimResultData(fileData)
            this.saveDataToLocalStorage(this.jsonData)
            this.currentResultId = null // New upload, not saved yet
            localStorage.removeItem('CSRO_CURRENT_RESULT_ID')
            this.currentView = 'table'
            this.uploaded = true
          } catch (error) {
            console.error('Error parsing JSON:', error)
          }
        }
        reader.readAsText(file)
      }
    },
    persist(key, value) {
      // Centralised localStorage write that never fails silently.
      // Returns true on success, false (with a loud report) on failure.
      try {
        localStorage.setItem(key, value)
        return true
      } catch (error) {
        const approxMB = (value.length / 1024 / 1024).toFixed(2)
        console.error(
          `[CSRO] Failed to save "${key}" (${approxMB} MB). localStorage is likely full ` +
            `(~5 MB cap). Error: ${error.name}`,
          error
        )
        this.showToast('Storage is full — delete some saved results and try again.', 6000)
        return false
      }
    },
    showToast(message, duration = 2500) {
      this.toast = message
      if (this.toastTimer) clearTimeout(this.toastTimer)
      this.toastTimer = setTimeout(() => {
        this.toast = ''
      }, duration)
    },
    trimResultData(data) {
      // Keep only the fields the app actually reads. The raw Assetto Corsa JSON
      // carries Events, Penalties, per-lap Conditions/Sectors, session config,
      // etc. — none of which are rendered — and those are what blow up storage.
      if (!data || typeof data !== 'object' || Array.isArray(data)) return data
      const trimCar = (c) => ({
        CarId: c.CarId,
        Model: c.Model,
        Driver: c.Driver
          ? { Name: c.Driver.Name, Team: c.Driver.Team, Nation: c.Driver.Nation }
          : c.Driver
      })
      const trimLap = (l) => ({
        CarId: l.CarId,
        DriverName: l.DriverName,
        LapTime: l.LapTime
      })
      return {
        Version: data.Version,
        Type: data.Type,
        Date: data.Date,
        TrackName: data.TrackName,
        EventName: data.EventName,
        Cars: Array.isArray(data.Cars) ? data.Cars.map(trimCar) : data.Cars,
        // Result rows are small and hold the user's inline edits (customPoints,
        // customBestLap, …) — preserve them untouched.
        Result: data.Result,
        Laps: Array.isArray(data.Laps) ? data.Laps.map(trimLap) : data.Laps
      }
    },
    compactStorage() {
      // One-time cleanup of data saved before trimming existed, so the user
      // doesn't have to re-upload everything. Idempotent: re-running is a no-op.
      let before = 0
      let after = 0

      if (this.savedResults.length) {
        const oldStr = JSON.stringify(this.savedResults)
        const trimmed = this.savedResults.map((r) => ({
          ...r,
          data: this.trimResultData(r.data)
        }))
        const newStr = JSON.stringify(trimmed)
        if (newStr.length < oldStr.length) {
          before += oldStr.length
          after += newStr.length
          if (this.persist('CSRO_SAVED_RESULTS', newStr)) {
            this.savedResults = trimmed
          }
        }
      }

      const current = localStorage.getItem('CSRO_RESULT')
      if (current) {
        try {
          const newStr = JSON.stringify(this.trimResultData(JSON.parse(current)))
          if (newStr.length < current.length) {
            before += current.length
            after += newStr.length
            this.persist('CSRO_RESULT', newStr)
          }
        } catch (error) {
          console.warn('[CSRO] Could not compact CSRO_RESULT:', error)
        }
      }

      if (after && after < before) {
        const saved = ((before - after) / 1024).toFixed(0)
        console.info(
          `[CSRO] Compacted storage: ${(before / 1024).toFixed(0)} KB → ` +
            `${(after / 1024).toFixed(0)} KB (freed ${saved} KB)`
        )
        this.showToast(`Compacted storage, freed ${saved} KB`, 4000)
      }
    },
    saveDataToLocalStorage(data) {
      const jsonData = JSON.stringify(data)
      this.persist('CSRO_RESULT', jsonData)
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
      // Restore currentResultId
      const savedCurrentResultId = localStorage.getItem('CSRO_CURRENT_RESULT_ID')
      if (savedCurrentResultId) {
        this.currentResultId = savedCurrentResultId
      }
    },
    updateResultsTable(data) {
      this.settings = data
      this.resultsTableKey += 1
    },
    saveResult(resultData) {
      // Open the in-app naming modal. We deliberately avoid native prompt():
      // browsers can block page dialogs ("prevent this page from creating
      // additional dialogs"), which made saves vanish with no error.
      this.saveModal = {
        open: true,
        name: resultData.suggestedName || 'Result',
        pending: resultData
      }
      this.$nextTick(() => {
        const input = this.$refs.saveNameInput
        if (input) {
          input.focus()
          input.select()
        }
      })
    },
    cancelSaveResult() {
      this.saveModal = { open: false, name: '', pending: null }
    },
    confirmSaveResult() {
      const resultName = this.saveModal.name.trim()
      const resultData = this.saveModal.pending
      if (!resultName || !resultData) return

      // Overwrite an existing result that shares this name
      const existingByName = this.savedResults.find((r) => r.name === resultName)

      let resultId = resultData.id
      if (existingByName && existingByName.id !== resultData.id) {
        resultId = existingByName.id
      } else if (!resultId) {
        resultId = Date.now().toString()
      }

      const result = {
        id: resultId,
        name: resultName,
        data: this.trimResultData(resultData.data),
        timestamp: Date.now()
      }

      // Build the next state without mutating component state yet, so a failed
      // persist leaves the in-memory list and storage in agreement.
      const existingIndex = this.savedResults.findIndex((r) => r.id === result.id)
      const nextResults =
        existingIndex !== -1
          ? this.savedResults.map((r, i) => (i === existingIndex ? result : r))
          : [...this.savedResults, result]

      // Only commit if the write actually succeeded
      if (!this.persist('CSRO_SAVED_RESULTS', JSON.stringify(nextResults))) return

      this.savedResults = nextResults
      this.currentResultId = result.id
      this.cancelSaveResult()
      this.showToast(`Saved “${resultName}”`)
    },
    loadSavedResult(resultId) {
      const result = this.savedResults.find((r) => r.id === resultId)
      if (result) {
        this.persist('CSRO_RESULT', JSON.stringify(result.data))
        localStorage.setItem('CSRO_CURRENT_RESULT_ID', result.id)
        this.currentResultId = result.id
        this.currentView = 'table'
        this.uploaded = true
        this.resultsTableKey += 1
        window.location.reload()
      }
    },
    deleteSavedResult(resultId) {
      const result = this.savedResults.find((r) => r.id === resultId)
      this.requestConfirm(
        {
          title: 'Delete result',
          message: `Delete “${result ? result.name : 'this result'}”? This can't be undone.`,
          confirmLabel: 'Delete',
          danger: true
        },
        () => this.performDeleteSavedResult(resultId)
      )
    },
    performDeleteSavedResult(resultId) {
      this.savedResults = this.savedResults.filter((r) => r.id !== resultId)
      this.persist('CSRO_SAVED_RESULTS', JSON.stringify(this.savedResults))

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
      this.requestConfirm(
        {
          title: 'Reset everything',
          message:
            'This permanently deletes all saved results, settings, and uploaded images. This cannot be undone.',
          confirmLabel: 'Delete everything',
          danger: true
        },
        () => {
          localStorage.clear()
          window.location.reload()
        }
      )
    },
    requestConfirm(options, onConfirm) {
      this.confirmDialog = {
        open: true,
        title: options.title,
        message: options.message,
        confirmLabel: options.confirmLabel || 'Confirm',
        danger: options.danger || false,
        onConfirm
      }
      this.$nextTick(() => {
        // Focus the dialog (not the destructive button) so Esc works without
        // making an accidental Enter trigger the dangerous action.
        const el = this.$refs.confirmCard
        if (el) el.focus()
      })
    },
    confirmDialogProceed() {
      const onConfirm = this.confirmDialog.onConfirm
      this.closeConfirmDialog()
      if (onConfirm) onConfirm()
    },
    closeConfirmDialog() {
      this.confirmDialog = {
        open: false,
        title: '',
        message: '',
        confirmLabel: 'Confirm',
        danger: false,
        onConfirm: null
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
    // Shrink anything saved before trimming existed (no re-upload needed)
    this.compactStorage()
  }
}
</script>
