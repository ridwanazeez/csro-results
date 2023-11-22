<template>
  <div class="flex">
    <div class="container m-auto py-12">
      <div
        v-if="tableData.Type == 'QUALIFY'"
        class="relative mb-5 flex w-full flex-col items-center text-center"
      >
        <h1 class="flex items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
          Qualifying Results
        </h1>
        <h2 class="flex items-center tracking-tight text-black">
          {{ formatDate(tableData.Date) }}
        </h2>
      </div>
      <div v-else class="relative mb-5 flex w-full flex-col items-center text-center">
        <h1 class="flex items-center text-2xl font-bold tracking-tight text-black sm:text-3xl">
          Race Results
        </h1>
      </div>
      <div class="overflow-hidden rounded-lg border border-gray-200 shadow-md dark:border-white">
        <table
          class="w-full border-collapse bg-white text-left text-sm text-gray-500 dark:bg-gray-800 dark:text-white"
        >
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th scope="col" class="px-6 py-4 font-medium text-gray-900 dark:text-white">#</th>
              <th scope="col" class="px-6 py-4 font-medium text-gray-900 dark:text-white">Name</th>
              <th scope="col" class="px-6 py-4 font-medium text-gray-900 dark:text-white">
                Country
              </th>
              <th scope="col" class="px-6 py-4 font-medium text-gray-900 dark:text-white">
                Total Time
              </th>
              <th scope="col" class="px-6 py-4 font-medium text-gray-900 dark:text-white">
                Best Lap
              </th>
              <th scope="col" class="px-6 py-4 font-medium text-gray-900 dark:text-white">
                # of Laps
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100 border-t border-gray-100 dark:border-white">
            <tr
              v-for="(result, resultIndex) of tableData.Result"
              :key="resultIndex"
              class="hover:bg-gray-50 dark:hover:bg-gray-700"
            >
              <th class="px-6 py-4 font-bold">{{ resultIndex + 1 }}</th>
              <td class="flex gap-3 px-6 py-4 font-normal text-gray-900 dark:text-white">
                {{ result.DriverName }}
              </td>
              <td class="px-6 py-4">COUNTRY</td>
              <td class="px-6 py-4">TOTAL TIME</td>
              <td class="px-6 py-4">BEST LAP</td>
              <td class="px-6 py-4">NUMBER OF LAPS</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      tableData: ''
    }
  },
  props: {
    // data: { type: Object, default: () => ({}) }
  },
  methods: {
    formatDate(inputDate) {
      // Input date string
      const dateString = inputDate

      // Create a new Date object from the input string
      const date = new Date(dateString)

      // Extract day, month, and year
      const day = date.getUTCDate()
      const month = date.getUTCMonth() + 1 // Months are zero-based, so add 1
      const year = date.getUTCFullYear()

      // Format day, month, and year as two-digit strings
      const formattedDay = day < 10 ? '0' + day : day
      const formattedMonth = month < 10 ? '0' + month : month

      // Construct the formatted date string
      const formattedDate = `${formattedDay}-${formattedMonth}-${year}`

      return formattedDate
    },
    // saveDataToLocalStorage() {
    //   const jsonData = JSON.stringify(this.data)
    //   localStorage.setItem('CSRO_RESULT', jsonData)
    // },
    loadDataFromLocalStorage() {
      const jsonData = localStorage.getItem('CSRO_RESULT')
      if (jsonData) {
        try {
          this.tableData = JSON.parse(jsonData)
        } catch (error) {
          console.error('Error parsing JSON from localStorage:', error)
        }
      }
    }
  },
  mounted() {
    // Load data from localStorage when the component is mounted
    this.loadDataFromLocalStorage()
  },
  watch: {
    // Save data to localStorage whenever the 'data' prop changes
    data: {
      handler: 'saveDataToLocalStorage',
      deep: true
    }
  }
}
</script>
