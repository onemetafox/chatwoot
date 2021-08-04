<template>
  <div class="wizard-body small-9 columns">
    <page-header
      :header-title="$t('MOONBOARD_SETTINGS.EDIT_FLOW.CREATE.TITLE')"
      :header-content="$t('MOONBOARD_SETTINGS.EDIT_FLOW.CREATE.DESC')"
    />
    <div class="row channels">
      <board-form
        v-if="showMoonboardForm"
        :on-submit="updateMoonboard"
        :submit-in-progress="false"
        :submit-button-text="$t('MOONBOARD_SETTINGS.EDIT_FLOW.CREATE.BUTTON_TEXT')"
        :form-data="moonboardData"
      />
      <spinner v-else /> 
    </div>
  </div>
</template>

<script>
import BoardForm from '../BoardForm';
import router from '../../../../index';
import PageHeader from '../../SettingsSubPageHeader';
import alertMixin from 'shared/mixins/alertMixin';

import { mapGetters } from 'vuex';
import Spinner from 'shared/components/Spinner';

export default {
  components: {
    BoardForm,
    PageHeader,
    Spinner,
  },
  mixins: [alertMixin],
  data() {
    return {
      enabledFeatures: {},
    };
  },
  computed: {
    moonboardData() {
      const { moonboardId } = this.$route.params;
      return this.$store.getters['moonboards/getMoonboard'](moonboardId);
    },
    showMoonboardForm() {
      const { id } = this.moonboardData;
      return id && !this.uiFlags.isFetching;
    },
    ...mapGetters({
      uiFlags: 'moonboards/getUIFlags',
    }),
  },
  methods: {
    async updateMoonboard(data) {
      try {
        const { moonboardId } = this.$route.params;
        console.log(this.$store.dispatch);
        await this.$store.dispatch('moonboards/update', {
          id: moonboardId,
          ...data,
        });

        router.replace({
          name: 'moonboards_add_items',
          params: {
            page: 'edit',
            moonboardId,
          },
        });
      } catch (error) {
        this.showAlert(this.$t('MOONBOARD_SETTINGS.MOONBOARD_FORM.ERROR_MESSAGE'));
      }
    },
  },
};
</script>
