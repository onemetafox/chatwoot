<template>
  <div class="md-layout mt-3 ad-sidebar">
    <div class="md-layout-item md-medium-size-30 md-xsmall-size-100 md-size-20 ad-leftdock">
      <md-card v-show="globalState.viewsearch">
        <md-card-header class="text-center">
          <strong class="title" style="color: blue;">Global Lists</strong>
        </md-card-header>
        <md-card-content>
          <p>No saved lists</p>
        </md-card-content>
      </md-card>
      <md-card v-show="globalState.viewsearch">
        <md-card-header class="text-center">
          <strong class="title" style="color: blue;">My lists</strong>
        </md-card-header>
        <md-card-content>
          <p>No saved lists</p>
        </md-card-content>
      </md-card>
      <md-card v-show="globalState.viewsearch">
        <md-card-header class="text-center">
          <strong class="title" style="color: blue;">Recent Items</strong>
        </md-card-header>
        <md-card-content>
          <p>map.((item, i)=> {iterature...})</p>
        </md-card-content>
      </md-card>
    </div>
    <div class="md-layout-item md-medium-size-70 md-xsmall-size-100 md-size-80">
      <zoom-center-transition :duration="10" mode="out-in">
        <router-view />
      </zoom-center-transition>
    </div>
  </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex';
import { ZoomCenterTransition } from "vue2-transitions";
import {notifyVue} from '../../../helper/notify';

export default {
  name: 'ad-sidebar',
  components: {
    ZoomCenterTransition,
  },
  props: {
    contactId: {
      type: [String, Number],
      default: 0,
    },
  },
  computed: {
    ...mapState({
      error: state => state.global.error,
      msg: state => state.global.msg,
    }),
    ...mapGetters({
      globalState: 'global/getState',
    }),
  },
  watch: {
    error(newValue, oldValue) {
      if (newValue) notifyVue({ t: 2500, m: newValue, c: 'warning', v: 'top', h: 'left' }, this)
    },
    msg(newValue, oldValue) {
      if (newValue) notifyVue({m: newValue, c: 'success'}, this)
    }
  },
};
</script>

<style lang="scss">
.md-button:not(.md-just-icon) .md-button-content i {
  height: -7px;
}
.md-progress-bar {
  position: absolute;
  top: 0;
  right: 0;
  left: 0;
}
.ad-sidebar {
  .md-card .md-card-header {
    padding: 0 12px;
  }
  .title {
    padding: 10px 0 0 0
  }
}
</style>
