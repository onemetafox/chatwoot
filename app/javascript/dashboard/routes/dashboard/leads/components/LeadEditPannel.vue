<template>
  <div class="medium-3 bg-white leads-edit-pannel">
    <span class="close-button" @click="onClose">
      <i class="ion-android-close close-icon" />
    </span>
    <LeadInfo />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import LeadInfo from './info';
export default {
  name: 'leads-edit-pannel',
  components: {
    LeadInfo
  },
  computed: {
    ...mapGetters({
      leadState: 'enLeads/getState'
    })
  },
  methods: {
    onClose() {
      Promise.all([
        this.$store.dispatch('enLeads/editID', -1),
        this.$store.dispatch('enLeads/editing', false),
        this.$store.dispatch('enLeads/lead', {})
      ])
    }
  },
};
</script>

<style lang="scss" scoped>
  ::v-deep {
    .lead-info {
      padding-bottom: var(--space-slab);
      margin-bottom: var(--space-normal);
    }
  }
  .leads-edit-pannel {
    height: 100%;
    background: white;
    font-size: var(--font-size-small);
    overflow-y: auto;
    overflow: auto;
    position: relative;
    border-left: 1px solid var(--color-border);
    padding: var(--space-medium) var(--space-two);
  }
</style>
