<template>
  <div class="column content-box">
    <div class="row">
      <div class="small-8 columns with-right-space ">
        <p v-if="!moonboardList.length" class="no-items-error-message">
          {{ $t('MOONBOARD_SETTINGS.LIST.404') }}
          <router-link v-if="isAdmin" :to="addAccountScoping('settings/moonboards/new')">
            {{ $t('MOONBOARD_SETTINGS.NEW') }}
          </router-link>
        </p>
        <table v-if="moonboardList.length" class="woot-table">
          <tbody>
            <tr v-for="item in moonboardList" :key="item.id">
              <td> {{ item.title }} </td>
              <td>
                <div class="button-wrapper">
                  <woot-button variant="link" color-scheme="secondary" icon="ion-archive" class-names="grey-btn" :is-loading="loading[item.id]" @click="Download(item)" >
                    {{ $t('MOONBOARD_SETTINGS.DOWNLOAD.BUTTON_TEXT') }}
                  </woot-button>
                  <router-link :to="addAccountScoping(`settings/moonboards/${item.id}/edit`)" >
                    <woot-button v-if="isAdmin" variant="link" color-scheme="secondary" class-names="grey-btn" icon="ion-gear-b" >
                      {{ $t('MOONBOARD_SETTINGS.LIST.EDIT') }}
                    </woot-button>
                  </router-link>
                  <woot-button v-if="isAdmin" variant="link" color-scheme="secondary" icon="ion-close-circled" class-names="grey-btn" :is-loading="loading[item.id]" @click="openDelete(item)" >
                    {{ $t('MOONBOARD_SETTINGS.DELETE.BUTTON_TEXT') }}
                  </woot-button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="small-4 columns">
        <span v-html="$t('MOONBOARD_SETTINGS.SIDEBAR_TXT', { installationName: globalConfig.installationName, })" />
      </div>
    </div>
    <woot-confirm-delete-modal
      :show.sync="showDeletePopup"
      :title="confirmDeleteTitle"
      :message="$t('MOONBOARD_SETTINGS.DELETE.CONFIRM.MESSAGE')"
      :confirm-text="deleteConfirmText"
      :reject-text="deleteRejectText"
      :confirm-value="selectedMoonboard.title"
      :confirm-place-holder-text="confirmPlaceHolderText"
      @on-confirm="confirmDeletion"
      @on-close="closeDelete"
    />
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import adminMixin from '../../../../mixins/isAdmin';
import accountMixin from '../../../../mixins/account';
import alertMixin from 'shared/mixins/alertMixin';

export default {
  components: {},
  mixins: [adminMixin, accountMixin, alertMixin],
  data() {
    return {
      loading: {},
      showSettings: false,
      showDeletePopup: false,
      selectedMoonboard: {},
    };
  },
  computed: {
    ...mapGetters({
      moonboardList: 'moonboards/getMoonboards',
      globalConfig: 'globalConfig/get',
    }),
    deleteConfirmText() {
      return `${this.$t('MOONBOARD_SETTINGS.DELETE.CONFIRM.YES')} ${
        this.selectedMoonboard.title
      }`;
    },
    deleteRejectText() {
      return this.$t('MOONBOARD_SETTINGS.DELETE.CONFIRM.NO');
    },
    confirmDeleteTitle() {
      return this.$t('MOONBOARD_SETTINGS.DELETE.CONFIRM.TITLE', {
        moonboardTitle: this.selectedMoonboard.title,
      });
    },
    confirmPlaceHolderText() {
      return `${this.$t('MOONBOARD_SETTINGS.DELETE.CONFIRM.PLACE_HOLDER', {
        moonboardTitle: this.selectedMoonboard.title,
      })}`;
    }
  },
  methods: {
    async deleteMoonboard({ id }) {
      try {
        await this.$store.dispatch('moonboards/delete', id);
        this.showAlert(this.$t('MOONBOARD_SETTINGS.DELETE.API.SUCCESS_MESSAGE'));
      } catch (error) {
        this.showAlert(this.$t('MOONBOARD_SETTINGS.DELETE.API.ERROR_MESSAGE'));
      }
    },
    confirmDeletion() {
      this.deleteMoonboard(this.selectedMoonboard);
      this.closeDelete();
    },
    openDelete(moonboard) {
      this.showDeletePopup = true;
      this.selectedMoonboard = moonboard;
    },
    closeDelete() {
      this.showDeletePopup = false;
      this.selectedMoonboard = {};
    },
    async Download(moonboard) {
      try {
        this.selectedMoonboard = moonboard;
        await this.$store.dispatch('moonboards/download', moonboard.id);
      } catch (error) {
        this.showAlert(this.$t('MOONBOARD_SETTINGS.DOWNLOAD.API.ERROR_MESSAGE'));
      }
    }
  },
};
</script>
<style lang="scss" scoped>
.button-wrapper {
  min-width: unset;
  justify-content: flex-end;
  padding-right: var(--space-large);
}
</style>
