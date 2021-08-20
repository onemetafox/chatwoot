<template>
  <div class="app-wrapper">
    <notifications />
    <sidebar :route="currentRoute"></sidebar>
    <section class="app-content columns" :class="contentClassName">
       <zoom-center-transition :duration="100" mode="out-in">
        <router-view></router-view>
      </zoom-center-transition>
    </section> 
  </div>
</template>

<script>
import { ZoomCenterTransition } from "vue2-transitions";
import Sidebar from '../../components/layout/Sidebar';

export default {
  components: {
    ZoomCenterTransition,
    Sidebar,
  },
  data() {
    return {
      isSidebarOpen: false,
      isOnDesktop: true,
    };
  },
  computed: {
    currentRoute() {
      return ' ';
    },
    sidebarClassName() {
      if (this.isOnDesktop) {
        return '';
      }
      if (this.isSidebarOpen) {
        return 'off-canvas is-open position-left';
      }
      return 'off-canvas position-left is-transition-push is-closed';
    },
    contentClassName() {
      if (this.isOnDesktop) {
        return '';
      }
      if (this.isSidebarOpen) {
        return 'off-canvas-content is-open-right has-transition-push has-position-left';
      }
      return 'off-canvas-content';
    },
  },
  mounted() {
    this.$store.dispatch('setCurrentAccountId', this.$route.params.accountId);
    window.addEventListener('resize', this.handleResize);
    this.handleResize();
    bus.$on('sidemenu_icon_click', () => {
      this.isSidebarOpen = !this.isSidebarOpen;
    });
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
  },
  methods: {
    handleResize() {
      if (window.innerWidth > 1200) {
        this.isOnDesktop = true;
      } else {
        this.isOnDesktop = false;
      }
    },
  },
};
</script>
<style lang="scss">
  $scaleSize: 0.95;
  @keyframes zoomIn95 {
    from {
      opacity: 0;
      transform: scale3d($scaleSize, $scaleSize, $scaleSize);
    }
    to {
      opacity: 1;
    }
  }
  .app-wrapper .zoomIn {
    animation-name: zoomIn95;
  }
  @keyframes zoomOut95 {
    from {
      opacity: 1;
    }
    to {
      opacity: 0;
      transform: scale3d($scaleSize, $scaleSize, $scaleSize);
    }
  }
  .app-wrapper .zoomOut {
    animation-name: zoomOut95;
  }
</style>
