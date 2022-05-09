<template>
  <div class="container">
    <h1>CSRO Timesheet Parser</h1>
    <div class="d-flex flex-column justify-content-center align-items-center">
      <div class="col-4">
        <form>
          <div class="mb-3">
            <label for="fileUpload" class="form-label">Upload JSON File</label>
            <input type="file" class="form-control" id="fileUpload" @change="handleFile" />
          </div>
        </form>
      </div>
    </div>
    <Table :data="output" />
  </div>
</template>

<script>
import Table from "./components/Table.vue";

export default {
  name: "App",
  components: {
    Table,
  },
  data() {
    return {
      output: [],
    };
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

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
