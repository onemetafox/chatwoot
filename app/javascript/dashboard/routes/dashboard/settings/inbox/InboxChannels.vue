<template>
  <div class="row content-box full-height">
    <woot-wizard
      class="small-3 columns"
      :global-config="globalConfig"
      :items="items"
    />
    <router-view></router-view>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import globalConfigMixin from 'shared/mixins/globalConfigMixin';

export default {
  mixins: [globalConfigMixin],
  computed: {
    ...mapGetters({
      globalConfig: 'globalConfig/get',
    }),
    items() {
      return this.$t('INBOX_MGMT.CREATE_FLOW', {
        projectName: globalConfig.installationName
      }).map(item => ({
        ...item,
        body: this.useInstallationName(
          item.body,
          this.globalConfig.installationName
        ),
      }));
    },
  },
};
</script>
