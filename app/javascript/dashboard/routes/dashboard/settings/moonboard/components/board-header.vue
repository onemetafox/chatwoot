<template>
  <div v-if="board" class="input-group">
    <input type="text" v-model="board.title" @change="updateBoard(board)" placeholder="Board title" class="form-control form-control-lg"/>
    <div class="input-group-append">
      <!-- button class="btn btn-outline-secondary" type="button">Delete</button-->
      <a :href="shareUrl" class="btn btn-lg btn-primary" type="button">Save & publish</a>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    name: 'boardHeader',
    data() {
      return {
        board: null
      }
    },
    mounted() {
      let boardId = document.querySelector('meta[name="board-id"]').getAttribute('content');
       axios.get(`/api/boards/${boardId}`).then((response) => {
          this.board = response.data
        }
      );
    },
    methods: {
      updateBoard: function(board) {
        if (board.title) {
          axios
            .patch(`/api/boards/${this.board.id}`, {
              title: board.title
            })
        }
      }
    },
    computed: {
      shareUrl: function() {
        return `/b/${this.board.share_id}`
      }
    }
  }
</script>
