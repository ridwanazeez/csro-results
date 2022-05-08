<template>
  <div class="d-flex flex-column min-vh-100 justify-content-center align-items-center">
    <div class="col-4">
      <form>
        <div class="mb-3">
          <label for="fileUpload" class="form-label">Upload JSON File</label>
          <input type="file" class="form-control" id="fileUpload" @change="handleFile" />
        </div>
      </form>
    </div>
    <!-- <p>{{ output }}</p> -->
    <!-- <div v-for="driver in output">
      {{ driver.DriverName }}
      {{ driver.BestLap }}
    </div> -->
  </div>
</template>

<script>
export default {
  data() {
    return {
      output: [],
    };
    props: [output];
  },
  methods: {
    handleFile(e) {
      let files = e.target.files || e.dataTransfer.files;
      if (!files.length) return;
      this.readFile(files[0]);
    },
    readFile(file) {
      let reader = new FileReader();
      reader.onload = (e) => {
        this.output = JSON.parse(e.target.result).Result;
        // let json = JSON.parse(e.target.result).Result;                //test, ignore
        // console.log(json);                                            //test output to console log
      };
      reader.readAsText(file);
    },
  },
};
</script>

<style></style>
