<template>
  <div>
    <board-packery :items="items" :editing="editing"></board-packery>
  </div>
</template>

<script>
  import boardPackery from './board-packery'
  import axios from 'axios'

  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  export default {
    name: 'boardShow',
    data() {
      return {
        items: [],
        editing: false
      }
    },
    mounted () {
      let boardId = document.querySelector('meta[name="board-id"]').getAttribute('content');
      axios.get(`/boards/${boardId}/items${window.location.search}`).then((response)=> {
          this.items = response.data
      })
    },
    components: {
      boardPackery
    }
  }
</script>
