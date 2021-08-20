<template>
  <div>
    <Edit :groups="groupState.groups" :users="userState.users"/>
    <md-card class="ad-groups">
      <md-card-header>
        <div class="d-flex justify-content-between align-baseline">
          <strong class="title" style="float: left; color: blue; font-weight: 700; padding-top: 10px;">Groups</strong>
          <md-button class="md-default md-raised md-dense" @click="showModal">create group</md-button>
        </div>
      </md-card-header>
      <md-card-content>
        <div v-for="(group,n) in groupState.groups" :key="'gs-'+n" class="group-info">
          <Detail :group="group"/>
          <md-divider class="md-hr md-theme-demo-light" />
        </div>
      </md-card-content>
    </md-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import store from '../../../../store'
import Edit from './edit.vue';
import Detail from './detail.vue';

export default {
  name: 'ad-groups',
  components: {
    Edit,
    Detail,
  },
  props: {
    contactId: {
      type: [String, Number],
      default: 0,
    },
  },
  computed: {
    ...mapGetters({
      groupState: 'adGroups/getState',
      userState: 'adUsers/getState',
    }),
  },
  beforeRouteEnter(to, from, next) {
    Promise.all([
      store.dispatch('adUsers/search'),
      store.dispatch('adGroups/get'),
    ]).then(() => {
      console.log(store)
      next();
    });
  },
  methods: {
    showModal() {
      this.$store.dispatch('adGroups/editID', null)
    }
  },
};
</script>

<style lang="scss">
.ad-groups {
  .md-card .md-card-header {
    padding: 0 12px;
  }
  p {
    margin-bottom: 0;
  }
}
</style>
