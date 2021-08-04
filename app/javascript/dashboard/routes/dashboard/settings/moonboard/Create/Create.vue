<template>
  <div class="wizard-body small-9 columns">
    <page-header
      :header-title="$t('MOONBOARD_SETTINGS.CREATE_FLOW.CREATE.TITLE')"
      :header-content="$t('MOONBOARD_SETTINGS.CREATE_FLOW.CREATE.DESC')"
    />
    <div class="row channels">
      <board-form
        :on-submit="createBoard"
        :submit-in-progress="false"
        :submit-button-text="$t('MOONBOARD_SETTINGS.FORM.SUBMIT_CREATE')"
      />
    </div>
  </div>
</template>

<script>
import BoardForm from '../BoardForm';
import router from '../../../../index';
import PageHeader from '../../SettingsSubPageHeader';
import alertMixin from 'shared/mixins/alertMixin';

export default {
  components: {
    BoardForm,
    PageHeader,
  },
  mixins: [alertMixin],
  data() {
    return {
      enabledFeatures: {},
    };
  },
  methods: {
    async createBoard(data) {
      try {
        const moonboard = await this.$store.dispatch('moonboards/create', {
          ...data,
        });
        
        router.replace({
          name: 'moonboards_add_items',
          params: {
            page: 'new',
            moonboardId: moonboard.id,
          },
        });
      } catch (error) {
        this.showAlert(this.$t('MOONBOARD_SETTINGS.MOONBOARD_FORM.ERROR_MESSAGE'));
      }
    },
  },
};
</script>
