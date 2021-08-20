<template>
  <div class="leads-page row">
    <div class="left-wrap" :class="wrapClass">
      <LeadsHeader />
      <LeadsTable :leads="leadState.leads" :query="leadState.query" :editID="leadState.editID"/>
    </div>
    <LeadsEditPan v-if="showEditPan" />
    <EditLead :show="leadState.editing" />
  </div>
</template>

<script>
  import { mapGetters } from "vuex";
  import store from 'dashboard/store';
  import LeadsHeader from './components/LeadHeader.vue';
  import LeadsTable from './components/LeadTable.vue';
  import LeadsEditPan from './components/LeadEditPannel.vue';
  import EditLead from './components/info/EditLead.vue'

  export default {
    name: 'entity-leads',
    components: {
      LeadsHeader,
      LeadsTable,
      LeadsEditPan,
      EditLead,
    },
    computed: {
      ...mapGetters({
        leadState: 'enLeads/getState'
      }),
      wrapClass() {
        return this.leadState.editID === -1 ? 'medium-12' : 'medium-9';
      },
      showEditPan() {
        return this.leadState.editID !== -1 && this.leadState.editID !== 'new';
      },
    },
    beforeRouteEnter(to, from, next) {
      store.dispatch('enLeads/search').then(() => {
        next()
      })
    },
  };
</script>
<style lang="scss" scoped>
  .leads-page {
    width: 100%;
  }
  .left-wrap {
    display: flex;
    flex-direction: column;
    height: 100%;
  }
  .strip {
    height: 25px;
    width: auto;
    background: #dcdcdc;
    color: black;
    float: left;
    font-size: 11px;
    margin: 0px 6px 0px 0px;
    padding: 1px 4px 1px 3px;
    text-align: right;
    width: 75px;
    -moz-border-radius-topleft: 7px;
    -moz-border-radius-bottomleft: 7px;
    -webkit-border-top-left-radius: 7px;
    -webkit-border-bottom-left-radius: 7px;
  }
</style>
