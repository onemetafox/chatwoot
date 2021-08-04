<template>
  <div>
    <board-dropzone :items="items" class="mb-4"></board-dropzone>
    <board-packery :items="items" :editing="editing"></board-packery>
  </div>
</template>

<script>
  import boardDropzone from './board-dropzone'
  import boardPackery from './board-packery'
  import axios from 'axios'

  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  export default {
    name: 'boardEditor',
    data() {
      return {
        items: [],
        editing: true
      }
    },
    mounted() {
      let boardId = document.querySelector('meta[name="board-id"]').getAttribute('content');
      axios.get(`/boards/${boardId}/items?all=true`).then((response)=> {
          this.items = response.data
      })
    },
    components: {
      boardDropzone,
      boardPackery
    }
  }
</script>
