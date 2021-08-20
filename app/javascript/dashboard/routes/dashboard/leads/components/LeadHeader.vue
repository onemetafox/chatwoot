<template>
  <header class="header">
    <div class="table-actions-wrap">
      <div class="left-aligned-wrap">
        <h1 class="page-title">
          {{ $t('LEADS_PAGE.HEADER') }}
        </h1>
      </div>
      <div class="right-aligned-wrap">
        <div class="search-wrap">
          <md-autocomplete
            class="search"
            v-model="leadState.query"
            :md-options="leadState.queryHistory"
            md-layout="box"
            style="padding-bottom: 0;"
          >
            <label>{{$t('LEADS_PAGE.SEARCH_INPUT_PLACEHOLDER')}}</label>
          </md-autocomplete>
          <md-button class="md-info md-raised md-dense" @click="createLead">
            {{ $t('LEADS_PAGE.CREATE_LEAD') }}
          </md-button>
        </div>
      </div>
    </div>
  </header>
</template>

<script>
  import { mapGetters } from "vuex";
  export default {
    name: 'leads-header',
    computed: {
      ...mapGetters({
        leadState: 'enLeads/getState'
      }),
    },
    methods: {
      createLead() {
        Promise.all([
          this.$store.dispatch('enLeads/editID', 'new'),
          this.$store.dispatch('enLeads/lead', {id: 'new'}),
          this.$store.dispatch('enLeads/editing', true)
        ])
      },
    },
  };
</script>

<style lang="scss" scoped>
  @import "~dashboard/assets/scss/md/variables";
  @import "~dashboard/assets/scss/md/mixins";
  @import "~dashboard/assets/scss/md/shadows";
  @import "~dashboard/assets/scss/md/colors";
  @import "~dashboard/assets/scss/md/buttons";
  @import "~dashboard/assets/scss/md/autocomplete";
  @import "~dashboard/assets/scss/md/inputs";
  .page-title {
    margin: 0;
  }
  .table-actions-wrap {
    display: flex;
    justify-content: space-between;
    width: 100%;
    padding: var(--space-small) var(--space-normal) var(--space-small)
      var(--space-normal);
  }
  .left-aligned-wrap {
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .right-aligned-wrap {
    display: flex;
  }
  .search-wrap {
    width: 400px;
    display: flex;
    align-items: center;
    position: relative;
    margin-right: var(--space-small);
    .search-icon {
      position: absolute;
      top: 1px;
      left: var(--space-one);
      height: 3.8rem;
      line-height: 3.6rem;
      font-size: var(--font-size-medium);
      color: var(--b-700);
    }
  }
</style>
<style lang="scss">
  .md-field .md-input, .md-field .md-textarea {
    margin-bottom: 0;
  }
</style>

