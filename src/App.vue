<template>
  <!-- Lock screen: nothing loads until the shared password is checked -->
  <div
    v-if="authState !== 'ready'"
    class="flex min-h-screen items-center justify-center bg-gray-900 px-4 py-12 text-white"
  >
    <div class="w-full max-w-sm">
      <img class="mx-auto w-48" :src="defaultLogo" alt="CSRO Logo" />
      <h1 class="mt-6 text-center text-2xl font-bold">CSRO Results Generator</h1>

      <p
        v-if="authState === 'loading'"
        class="mt-8 text-center text-sm text-gray-400"
        role="status"
      >
        Loading results…
      </p>

      <div v-else-if="authState === 'unconfigured'" class="mt-8 rounded-md bg-gray-800 p-4 text-sm">
        <p class="font-semibold">Database not connected</p>
        <p class="mt-1 text-gray-300">
          Set <code>VITE_SUPABASE_URL</code> and <code>VITE_SUPABASE_KEY</code> in
          <code>.env.local</code>, then restart the dev server. The README has the steps.
        </p>
      </div>

      <form v-else class="mt-8 space-y-4" @submit.prevent="submitAuth">
        <div>
          <h2 class="text-lg font-semibold">
            {{ authState === 'setup' ? 'Set a password' : 'Enter password' }}
          </h2>
          <p class="mt-1 text-sm text-gray-400">
            <template v-if="authState === 'setup'">
              Admins use this password to open the same results on any device. Anyone who has it can
              edit and delete everything, so make it long.
            </template>
            <template v-else
              >Results are shared across devices. Enter the admin password to load them.</template
            >
          </p>
        </div>
        <div>
          <label for="authPassword" class="block text-sm font-medium text-gray-300">Password</label>
          <input
            id="authPassword"
            v-model="authForm.password"
            type="password"
            :autocomplete="authState === 'setup' ? 'new-password' : 'current-password'"
            required
            autofocus
            class="mt-1 w-full rounded-md border-0 bg-gray-800 text-white ring-1 ring-inset ring-gray-600 focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div v-if="authState === 'setup'">
          <label for="authConfirm" class="block text-sm font-medium text-gray-300">
            Confirm password
          </label>
          <input
            id="authConfirm"
            v-model="authForm.confirm"
            type="password"
            autocomplete="new-password"
            required
            class="mt-1 w-full rounded-md border-0 bg-gray-800 text-white ring-1 ring-inset ring-gray-600 focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <p v-if="authForm.error" class="text-sm text-red-400" role="alert">{{ authForm.error }}</p>
        <button
          type="submit"
          :disabled="authForm.busy"
          class="w-full rounded-md bg-blue-600 px-4 py-2 font-bold hover:bg-blue-700 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-900 disabled:cursor-wait disabled:opacity-60"
        >
          {{ authForm.busy ? 'Checking…' : authState === 'setup' ? 'Set password' : 'Unlock' }}
        </button>
      </form>
    </div>
  </div>

  <div v-else class="flex dark:bg-gray-900 w-full min-h-screen">
    <SideNav
      @settings="updateSettings"
      @load-result="loadSavedResult"
      @delete-result="deleteSavedResult"
      @view-standings="viewStandings"
      @global-reset="globalReset"
      @save-changes="handleSaveChanges"
      @screenshot="handleScreenshot"
      @back-to-table="backToTable"
      @new-upload="newUpload"
      @lock="lock()"
      :saved-results="savedResults"
      :current-view="currentView"
      :settings="settings"
    ></SideNav>
    <div class="mx-auto px-6 lg:px-8 max-w-[80%]">
      <div class="mx-auto">
        <div
          v-if="!currentData && currentView === 'table'"
          class="flex min-h-screen flex-col justify-center py-12"
        >
          <img class="mx-auto w-full max-w-sm" :src="defaultLogo" alt="CSRO Logo" />
          <h1 class="mt-4 text-3xl text-center font-bold dark:text-white">
            CSRO Results Generator
          </h1>
          <p class="text-center text-sm dark:text-white">
            v{{ version }} | Last updated: 04/10/2026
          </p>
          <p class="mt-6 text-center text-sm text-gray-600 dark:text-gray-300">
            Upload an Assetto Corsa results file, or open a saved result from the sidebar.
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
                  accept=".json,application/json"
                  class="sr-only"
                  @change="handleFileUpload"
                />
              </label>
            </div>
          </form>
        </div>
        <ResultsTable
          v-if="currentData && currentView === 'table'"
          ref="resultsTable"
          :race-data="settings"
          :result-data="currentData"
          :current-result-id="currentResultId"
          :key="resultsTableKey"
          @save-result="saveResult"
        ></ResultsTable>
        <StandingsView
          v-if="currentView === 'standings'"
          ref="standingsView"
          :key="resultsTableKey"
          :saved-results="savedResults"
          :settings="settings"
          :initial-adjustments="pointAdjustments"
          @adjustments="saveAdjustments"
        ></StandingsView>
      </div>
    </div>

    <!-- Name & Save Result Modal (replaces native prompt, which browsers can block) -->
    <div
      v-if="saveModal.open"
      class="fixed inset-0 bg-black/50 flex items-center justify-center z-50"
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
      class="fixed inset-0 bg-black/50 flex items-center justify-center z-50"
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
import { configured, rpc, WRONG_PASSWORD } from './db.js'

const DEFAULT_SETTINGS = {
  seriesTitle: 'CSRO Championship',
  resultsTitle: '',
  seriesLogo: null,
  mainLogo: null,
  enablePoints: false
}

// Keys from before data moved to Supabase; imported once, then removed
const LEGACY_KEYS = ['CSRO_RESULT', 'CSRO_SAVED_RESULTS', 'CSRO_SETTINGS', 'CSRO_POINT_ADJUSTMENTS']

export default {
  components: { ResultsTable, SideNav, StandingsView },
  data() {
    return {
      // 'loading' | 'unconfigured' | 'setup' | 'locked' | 'ready'
      authState: 'loading',
      authForm: { password: '', confirm: '', error: '', busy: false },
      password: localStorage.getItem('CSRO_PASSWORD'),
      defaultLogo: import.meta.env.BASE_URL + 'images/csro-logo.png',
      currentData: null,
      settings: { ...DEFAULT_SETTINGS },
      settingsTimer: null,
      pointAdjustments: {},
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
    async init() {
      if (!configured) {
        this.authState = 'unconfigured'
        return
      }
      try {
        if (!(await rpc('csro_status'))) {
          this.authState = 'setup'
        } else if (this.password) {
          await this.unlock(this.password)
        } else {
          this.authState = 'locked'
        }
      } catch (error) {
        if (error.code === WRONG_PASSWORD) {
          this.lock('The password has changed. Enter the new one.')
        } else {
          // Keep the remembered password; this is probably just the network
          this.authForm.error = `Couldn't reach the database: ${error.message}`
          this.authState = 'locked'
        }
      }
    },
    async submitAuth() {
      const { password, confirm } = this.authForm
      if (this.authState === 'setup') {
        if (password.length < 8) {
          this.authForm.error = 'Use at least 8 characters.'
          return
        }
        if (password !== confirm) {
          this.authForm.error = "The passwords don't match."
          return
        }
      }
      this.authForm.busy = true
      this.authForm.error = ''
      try {
        if (this.authState === 'setup') await rpc('csro_setup', { p_password: password })
        await this.unlock(password)
        this.authForm = { password: '', confirm: '', error: '', busy: false }
      } catch (error) {
        this.authForm.busy = false
        this.authForm.error =
          error.code === WRONG_PASSWORD ? "That password isn't right." : error.message
      }
    },
    async unlock(password) {
      let workspace = await rpc('csro_load', { p_password: password })
      this.password = password
      localStorage.setItem('CSRO_PASSWORD', password)
      if (await this.importLegacyData(workspace)) {
        workspace = await rpc('csro_load', { p_password: password })
      }
      this.settings = { ...DEFAULT_SETTINGS, ...workspace.settings }
      this.pointAdjustments = workspace.pointAdjustments
      this.savedResults = workspace.results

      // Reopen the result this device was last looking at
      const lastId = localStorage.getItem('CSRO_CURRENT_RESULT_ID')
      const last = this.savedResults.find((r) => r.id === lastId)
      if (last && !this.currentData) this.openResult(last)
      else this.currentResultId = last ? last.id : null
      this.authState = 'ready'
    },
    lock(message = '') {
      this.password = null
      localStorage.removeItem('CSRO_PASSWORD')
      this.currentData = null
      this.savedResults = []
      this.authForm = { password: '', confirm: '', error: message, busy: false }
      this.authState = 'locked'
    },
    // Every write goes through here so a password changed elsewhere locks the app
    async call(fn, args = {}) {
      try {
        return await rpc(fn, { p_password: this.password, ...args })
      } catch (error) {
        if (error.code === WRONG_PASSWORD) this.lock('The password has changed. Enter the new one.')
        throw error
      }
    },
    async importLegacyData(workspace) {
      // One-time move of results saved in this browser before the Supabase
      // switch. Local copies are only removed once every upload has succeeded.
      const read = (key) => {
        try {
          return JSON.parse(localStorage.getItem(key))
        } catch {
          return null
        }
      }
      const results = read('CSRO_SAVED_RESULTS') || []
      const settings = read('CSRO_SETTINGS')
      const adjustments = read('CSRO_POINT_ADJUSTMENTS')
      const draft = read('CSRO_RESULT') // unsaved working copy
      if (!results.length && !settings && !adjustments && !draft) return false

      const taken = new Set(workspace.results.flatMap((r) => [r.id, r.name]))
      for (const r of results) {
        if (taken.has(r.id) || taken.has(r.name)) continue
        await this.call('csro_save_result', {
          p_id: r.id,
          p_name: r.name,
          p_data: this.trimResultData(r.data)
        })
      }
      if (settings && !Object.keys(workspace.settings).length) {
        await this.call('csro_save_settings', { p_settings: settings })
      }
      if (adjustments && !Object.keys(workspace.pointAdjustments).length) {
        await this.call('csro_save_adjustments', { p_adjustments: adjustments })
      }
      LEGACY_KEYS.forEach((key) => localStorage.removeItem(key))
      if (draft) this.currentData = this.trimResultData(draft)
      this.showToast("Moved this browser's saved data to the database", 5000)
      return true
    },
    handleFileUpload(event) {
      const file = event.target.files[0]

      if (file) {
        const reader = new FileReader()

        reader.onload = () => {
          try {
            // Strip the heavy fields the app never reads before anything is stored
            this.currentData = this.trimResultData(JSON.parse(reader.result))
            this.setCurrentResultId(null) // New upload, not saved yet
            this.currentView = 'table'
            this.resultsTableKey += 1
          } catch (error) {
            console.error('Error parsing JSON:', error)
            this.showToast("That file isn't valid Assetto Corsa results JSON.", 5000)
          }
        }
        reader.readAsText(file)
      }
    },
    setCurrentResultId(id) {
      this.currentResultId = id
      if (id) localStorage.setItem('CSRO_CURRENT_RESULT_ID', id)
      else localStorage.removeItem('CSRO_CURRENT_RESULT_ID')
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
      // etc. — none of which are rendered.
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
    updateSettings(data) {
      this.settings = data
      this.resultsTableKey += 1
      // Settings change per keystroke; write once typing pauses
      clearTimeout(this.settingsTimer)
      this.settingsTimer = setTimeout(() => {
        this.call('csro_save_settings', { p_settings: data }).catch((error) =>
          this.showToast(`Couldn't save settings: ${error.message}`, 6000)
        )
      }, 800)
    },
    async saveAdjustments(adjustments) {
      this.pointAdjustments = adjustments
      try {
        await this.call('csro_save_adjustments', { p_adjustments: adjustments })
      } catch (error) {
        this.showToast(`Couldn't save points: ${error.message}`, 6000)
      }
    },
    saveResult(resultData) {
      // Keep the edited copy as the working result even if the save is cancelled
      this.currentData = resultData.data
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
    async confirmSaveResult() {
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
        // Snapshot, so later unsaved edits to the working copy don't leak into it
        data: JSON.parse(JSON.stringify(this.trimResultData(resultData.data))),
        timestamp: Date.now()
      }

      try {
        await this.call('csro_save_result', {
          p_id: result.id,
          p_name: result.name,
          p_data: result.data
        })
      } catch (error) {
        this.showToast(`Couldn't save “${resultName}”: ${error.message}`, 6000)
        return
      }

      const existingIndex = this.savedResults.findIndex((r) => r.id === result.id)
      this.savedResults =
        existingIndex !== -1
          ? this.savedResults.map((r, i) => (i === existingIndex ? result : r))
          : [...this.savedResults, result]
      this.setCurrentResultId(result.id)
      this.cancelSaveResult()
      this.showToast(`Saved “${resultName}”`)
    },
    openResult(result) {
      // Work on a copy so unsaved edits don't change the saved result
      this.currentData = JSON.parse(JSON.stringify(result.data))
      this.setCurrentResultId(result.id)
      this.currentView = 'table'
      this.resultsTableKey += 1
    },
    loadSavedResult(resultId) {
      const result = this.savedResults.find((r) => r.id === resultId)
      if (result) this.openResult(result)
    },
    newUpload() {
      this.currentData = null
      this.setCurrentResultId(null)
      this.currentView = 'table'
    },
    deleteSavedResult(resultId) {
      const result = this.savedResults.find((r) => r.id === resultId)
      this.requestConfirm(
        {
          title: 'Delete result',
          message: `Delete “${result ? result.name : 'this result'}” for everyone? This can't be undone.`,
          confirmLabel: 'Delete',
          danger: true
        },
        () => this.performDeleteSavedResult(resultId)
      )
    },
    async performDeleteSavedResult(resultId) {
      try {
        await this.call('csro_delete_result', { p_id: resultId })
      } catch (error) {
        this.showToast(`Couldn't delete: ${error.message}`, 6000)
        return
      }
      this.savedResults = this.savedResults.filter((r) => r.id !== resultId)

      // If deleting current result, clear the current data
      if (this.currentResultId === resultId) this.newUpload()

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
            'This permanently deletes all saved results, settings, and uploaded images for every device. The password stays the same. This cannot be undone.',
          confirmLabel: 'Delete everything',
          danger: true
        },
        async () => {
          try {
            await this.call('csro_reset')
            localStorage.removeItem('CSRO_CURRENT_RESULT_ID')
            window.location.reload()
          } catch (error) {
            this.showToast(`Couldn't reset: ${error.message}`, 6000)
          }
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
    this.init()
  }
}
</script>
