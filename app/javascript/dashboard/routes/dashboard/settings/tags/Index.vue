<template>
  <div class="column content-box">
    <woot-button
      color-scheme="success"
      class-names="button--fixed-right-top"
      icon="ion-android-add-circle"
      @click="openAddPopup()"
    >
      {{ $t('TAG_MGMT.HEADER_BTN_TXT') }}
    </woot-button>

    <!-- List Agents -->
    <div class="row">
      <div class="small-8 columns">
        <div>
          <p v-if="!tagState.tags.length">
            {{ $t('TAG_MGMT.LIST.404') }}
          </p>
          <table v-else class="woot-table">
            <tbody>
              <tr v-for="(tag, index) in tagState.tags" :key="'ts-'+index">
                <!-- Agent Name + Email -->
                <td>
                  <span class="tag-name">{{ tag.name }}</span>
                </td>
                <!-- Actions -->
                <td>
                  <div class="button-wrapper">
                    <woot-button
                      v-if="showEditAction(tag)"
                      variant="link"
                      color-scheme="secondary"
                      icon="ion-edit"
                      class-names="grey-btn"
                      @click="openEditPopup(tag)"
                    >
                      {{ $t('TAG_MGMT.EDIT.BUTTON_TEXT') }}
                    </woot-button>
                    <woot-button
                      v-if="showDeleteAction(tag)"
                      variant="link"
                      color-scheme="secondary"
                      icon="ion-close-circled"
                      class-names="grey-btn"
                      @click="openDeletePopup(tag, index)"
                    >
                      {{ $t('TAG_MGMT.DELETE.BUTTON_TEXT') }}
                    </woot-button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- Add Agent -->
    <woot-modal :show.sync="showAddPopup" :on-close="hideAddPopup">
      <add-tag :on-close="hideAddPopup" />
    </woot-modal>
    <!-- Edit Agent -->
    <woot-modal :show.sync="showEditPopup" :on-close="hideEditPopup">
      <edit-tag
        v-if="showEditPopup"
        :id="currentAgent.id"
        :name="currentAgent.name"
        :on-close="hideEditPopup"
      />
    </woot-modal>
    <!-- Delete Agent -->
    <woot-delete-modal
      :show.sync="showDeletePopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="$t('TAG_MGMT.DELETE.CONFIRM.TITLE')"
      :message="deleteMessage"
      :confirm-text="deleteConfirmText"
      :reject-text="deleteRejectText"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import globalConfigMixin from 'shared/mixins/globalConfigMixin';
import AddTag from './AddTag.vue';
import EditTag from './EditTag';
import store from 'dashboard/store';

export default {
  components: {
    AddTag,
    EditTag,
  },
  mixins: [globalConfigMixin],
  data() {
    return {
      loading: {},
      showAddPopup: false,
      showDeletePopup: false,
      showEditPopup: false,
      tagAPI: {
        message: '',
      },
      currentAgent: {},
    };
  },
  beforeRouteEnter(to, from, next) {
    store.dispatch('adTags/get').then(() => {
      next();
    });
  },
  computed: {
    ...mapGetters({
      tagState: 'adTags/getState',
      globalConfig: 'globalConfig/get',
    }),
    deleteConfirmText() {
      return `${this.$t('TAG_MGMT.DELETE.CONFIRM.YES')} ${
        this.currentAgent.name
      }`;
    },
    deleteRejectText() {
      return `${this.$t('TAG_MGMT.DELETE.CONFIRM.NO')} ${
        this.currentAgent.name
      }`;
    },
    deleteMessage() {
      return `${this.$t('TAG_MGMT.DELETE.CONFIRM.MESSAGE')} ${
        this.currentAgent.name
      } ?`;
    },
  },
  mounted() {
    this.$store.dispatch('tags/get');
  },
  methods: {
    showEditAction(tag) {
      return this.currentTagId !== tag.id;
    },
    showDeleteAction(tag) {
      if (this.currentTagId === tag.id) {
        return false;
      }

      if (!tag.confirmed) {
        return true;
      }

      if (tag.role === 'administrator') {
        return this.verifiedAdministrators().length !== 1;
      }
      return true;
    },
    verifiedAdministrators() {
      return this.tagList.filter(
        tag => tag.role === 'administrator' && tag.confirmed
      );
    },
    // Edit Function
    openAddPopup() {
      this.showAddPopup = true;
    },
    hideAddPopup() {
      this.showAddPopup = false;
    },

    // Edit Function
    openEditPopup(tag) {
      this.showEditPopup = true;
      this.currentAgent = tag;
    },
    hideEditPopup() {
      this.showEditPopup = false;
    },

    // Delete Function
    openDeletePopup(tag) {
      this.showDeletePopup = true;
      this.currentAgent = tag;
    },
    closeDeletePopup() {
      this.showDeletePopup = false;
    },
    confirmDeletion() {
      this.loading[this.currentAgent.id] = true;
      this.closeDeletePopup();
      this.deleteAgent(this.currentAgent.id);
    },
    async deleteAgent(id) {
      try {
        this.$store.dispatch('adTags/delete', id).then(() => {
          this.$store.dispatch('adTags/get').then(() => {
            this.$store.dispatch('global/setMsg', `Deleted "${tmp}" tag..`)
          })
        })
        this.showAlert(this.$t('TAG_MGMT.DELETE.API.SUCCESS_MESSAGE'));
      } catch (error) {
        this.showAlert(this.$t('TAG_MGMT.DELETE.API.ERROR_MESSAGE'));
      }
    },
    // Show SnackBar
    showAlert(message) {
      // Reset loading, current selected tag
      this.loading[this.currentAgent.id] = false;
      this.currentAgent = {};
      // Show message
      this.tagAPI.message = message;
      bus.$emit('newToastMessage', message);
    },
  },
};
</script>
