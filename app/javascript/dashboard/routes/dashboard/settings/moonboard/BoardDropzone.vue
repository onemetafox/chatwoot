<template>
  <div>
    <vue-dropzone
      id="dropzone"
      ref="dropzone"
      :options="dropzoneOptions"
      @vdropzone-success="uploadComplete"
      >
    </vue-dropzone>
  </div>
</template>

<script>
  import vue2Dropzone from 'vue2-dropzone'
  import APIClient from '../../../../api/ApiClient';

  export default {
    name: 'boardDropzone',
    components: {
      vueDropzone: vue2Dropzone
    },
    props: {
      items: Array
    },
    data: function () {
      let API = new APIClient;
      const accountId = window.location.pathname.split('/')[3];
      const moonboardId = this.$route.params.moonboardId;
      let url = `${API.baseUrl()}/accounts/${accountId}/moonboards/${moonboardId}/moonboard_items`;
      return {
        dropzoneOptions: {
          url: url,
          thumbnailWidth: 150, // px
          thumbnailHeight: 150,
          paramName: "image",
          maxFilesize: 10, // MB
          addRemoveLinks: true,
          dictDefaultMessage: "<i icon='ion-upload'></i> Drop files here to upload",
          params: {
          },
          headers: {
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          }
        }
      }
    },
    computed: {
    },
    mounted() {
    },
    methods: {
      uploadComplete: function(file, response) {
        console.log(response);
        this.items.push(response)
        this.$refs.dropzone.removeFile(file)
      }
    }
  }
</script>
<style lang="css" scoped>
  .dz-default{
    font-size: 20px;
  }
  .dropzone {
    margin-bottom: 20px;
  }
</style>

