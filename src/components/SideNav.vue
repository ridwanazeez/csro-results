<template>
  <aside class="w-64 bg-gray-800 text-white p-4">
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
          name="seriesTitle"
          class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6"
        ></textarea>
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

        <img v-if="seriesLogo" :src="seriesLogo" alt="Selected Image" />
      </div>
      <div>
        <button
          class="mt-4 rounded-md bg-green-600 hover:bg-green-700 p-2 text-base text-white"
          @click="saveSettings"
        >
          Save
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
        }

        reader.readAsDataURL(file)
      }
    },
    saveSettings() {
      this.$emit('settings', { seriesTitle: this.seriesTitle, seriesLogo: 'key2' })
    }
  },
  mounted() {
    this.saveSettings()
  }
}
</script>
