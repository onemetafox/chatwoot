<template>
  <div
    class="dashboard"
    v-packery="{
      itemSelector: '.dashboard-item',
      columnWidth: '.grid-sizer',
      gutter: '.gutter-sizer',
      stagger: 0
    }"
  >
    <div v-if="showEmptyMessage">
      This board is empty.
    </div>

    <div
      v-if="editing"
      class="dashboard-item"
      v-for='item in orderedItems'
      v-packery-item
      v-draggabilly
      :key="item.position"
      :data-packery="{
        columns: 1,
        rows: 2
      }"
      :data-id="item.id"
    >
      <board-item :item="item" :items="orderedItems" :editing="editing"></board-item>
    </div>
  </div>
</template>


<script>
  import { packeryEvents } from "vue-packery-plugin";
  import boardItem from './board-item'

  export default {
    name: 'boardPackery',
    props: {
      items: Array,
      editing: Boolean
    },
    methods: {

    },
    computed: {
      orderedItems: function () {
        return this.items.sort((a, b) => parseFloat(a.position) - parseFloat(b.position));
      },
      showEmptyMessage: function() {
        return this.items.length == 0 && !this.editing
      }
    },
    components: {
      boardItem
    }
  };
</script>
