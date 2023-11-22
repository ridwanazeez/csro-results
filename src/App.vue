<template>
  <div class="flex dark:bg-gray-900 sm:h-screen w-full">
    <div class="m-auto px-6 lg:px-8 max-w-7xl">
      <div class="mx-auto">
        <div v-if="!uploaded">
          <h1 class="text-3xl text-center font-bold">CSRO Timesheet Parser</h1>
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
        <ResultsTable v-if="uploaded"></ResultsTable>
      </div>
    </div>
  </div>
</template>

<script>
import ResultsTable from './components/ResultsTable.vue'

export default {
  components: {
    ResultsTable
  },
  data() {
    return {
      jsonData: [],
      uploaded: false
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
    }
  },
  mounted() {
    this.loadDataFromLocalStorage()
  }
}
</script>
