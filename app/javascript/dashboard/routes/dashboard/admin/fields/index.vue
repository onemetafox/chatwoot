<template>
  <div>
    <EditGroup :fieldState="fieldState" :tagState="tagState" />
    <md-card class="ad-fields">
      <md-card-header>
        <strong class="title" style="float: left; color: blue; font-weight: 700; padding-top: 10px;">Custom Fields</strong>
      </md-card-header>
      <md-card-content>
        <strong class="title" slot="header-title" style="padding: 0; text-align: left; color: black;">
          Custom fields are displayed in groups. Create a new field group, or add fields to one of the groups below. You can drag and drop fields to change their display order or move them between field groups.
        </strong>
        <div class="d-flex justify-content-between align-baseline">
          <strong style="color: red;">
            It is strongly recommended you restart your server after adding or removing any custom field.
          </strong>
          <md-button class="md-default md-raised md-dense" @click="showModal">create field group</md-button>
        </div>
        <tabs
          :tab-name="Object.keys(fieldState.categories)"
          color-button="warning"
          style="box-shadow: none; margin: 0;"
          class="field-tabs"
          :activeInx="Object.keys(fieldState.categories).indexOf(fieldState.selectCatename) > -1 ? Object.keys(fieldState.categories).indexOf(fieldState.selectCatename) : 0"
          @tabchange="tabChange"
        >
          <template slot="tab-pane-1">
            <div v-for="(g, n) in fieldState.categories[Object.keys(fieldState.categories)[0]]" :key="`gacc-${n}`">
              <Group :group="g" :ceFieldData="fieldState.ceFieldData" :selectCatename="fieldState.selectCatename" />
            </div>
          </template>
          <template slot="tab-pane-2">
            <div v-for="(g, n) in fieldState.categories[Object.keys(fieldState.categories)[1]]" :key="`gcom-${n}`">
              <Group :group="g" :ceFieldData="fieldState.ceFieldData" :selectCatename="fieldState.selectCatename" />
            </div>
          </template>
          <template slot="tab-pane-3">
            <div v-for="(g, n) in fieldState.categories[Object.keys(fieldState.categories)[2]]" :key="`gcon-${n}`">
              <Group :group="g" :ceFieldData="fieldState.ceFieldData" :selectCatename="fieldState.selectCatename" />
            </div>
          </template>
          <template slot="tab-pane-4">
            <div v-for="(g, n) in fieldState.categories[Object.keys(fieldState.categories)[3]]" :key="`glead-${n}`">
              <Group :group="g" :ceFieldData="fieldState.ceFieldData" :selectCatename="fieldState.selectCatename" />
            </div>
          </template>
          <template slot="tab-pane-5">
            <div v-for="(g, n) in fieldState.categories[Object.keys(fieldState.categories)[4]]" :key="`gopp-${n}`">
              <Group :group="g" :ceFieldData="fieldState.ceFieldData" :selectCatename="fieldState.selectCatename" />
            </div>
          </template>
        </tabs>
      </md-card-content>
    </md-card>
  </div>
</template>

<script>
import { mapState, mapGetters} from "vuex"
import store from '../../../../store'
import { Tabs } from '../../../../components/md';
import EditGroup from './editGroup.vue'
import Group from './group.vue'

export default {
  name: 'ad-fields',
  components: {
    Tabs,
    EditGroup,
    Group,
  },
  beforeRouteEnter(to, from, next) {
    Promise.all([
      store.dispatch('adFields/gSearch', 'Account'),
      store.dispatch('adTags/get')
    ]).then(() => {
      next();
    });
  },
  computed: {
    ...mapGetters({
      fieldState: 'adFields/getState',
      tagState: 'adTags/getState'
    }),
  },
  methods: {
    tabChange(active) {
      Promise.all([
        this.$store.dispatch('adFields/selectCatename', active),
        this.$store.dispatch('adFields/gSearch', active),
        this.$store.dispatch('adTags/get')
      ])
    },
    showModal() {
      Promise.all([
        this.$store.dispatch('adTags/get'),
        this.$store.dispatch('adFields/setCEGroupID', null),
      ]).then(() => {
        this.$bvModal.show('ceGroupModal');
      });
    },
  }
};
</script>
<style src="../../../../assets/css/demo.css"></style>
<style lang="scss">
.ad-fields {
  .md-card .md-card-header {
    padding: 0 12px;
  }
  .md-card-tabs .md-list .md-list-item .md-list-item-button .md-list-item-content {
    padding: 0;
  }
  .md-card-tabs .md-list .md-list-item .md-list-item-button {
      line-height: 20px;
  }
  .md-card-stats .md-card-content {
    text-align: left;
  }
  .field-tabs {
    .tab-content {
      display: inline;
    }
  }
}
</style>
