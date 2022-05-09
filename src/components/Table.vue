<template>
  <table class="table table-striped table-hover">
    <thead class="table-dark">
      <tr>
        <th scope="col">#</th>
        <th scope="col">Name</th>
        <th scope="col">Best Lap</th>
        <th scope="col">Total Time</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="(driver, index) in data">
        <th scope="row">{{ index + 1 }}</th>
        <td>{{ driver.DriverName }}</td>
        <td>{{ laps[index] }}</td>
        <td>{{ driver.TotalTime }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script>
export default {
  props: {
    data: {
      type: Array,
    },
    laps: {
      type: Array,
    },
  },
};
</script>

<style></style>
