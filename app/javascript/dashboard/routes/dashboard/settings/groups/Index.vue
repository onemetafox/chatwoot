<template>
  <div class="column content-box">
    <woot-button
      color-scheme="success"
      class-names="button--fixed-right-top"
      icon="ion-android-add-circle"
      @click="openAddPopup()"
    >
      {{ $t('GROUP_MGMT.HEADER_BTN_TXT') }}
    </woot-button>

    <!-- List Groups -->
    <div class="row">
      <div class="small-12 columns">
        <div>
          <p v-if="!groupState.groups.length">
            {{ $t('GROUP_MGMT.LIST.404') }}
          </p>
          <table v-else class="woot-table">
            <tbody>
              <tr v-for="(group, index) in groupState.groups" :key="'ts-'+index">
                <!-- Group Name + Email -->
                <td>
                  <span class="group-name">{{ group.name }}</span>
                </td>
                <td>
                  <label v-for="(user, index) in group.users" :key = "'user-'+index">
                    <span class="group-">{{ user.name }}</span>
                  </label>
                </td>
                <!-- Actions -->
                <td>
                  <div class="button-wrapper">
                    <woot-button
                      v-if="showEditAction(group)"
                      variant="link"
                      color-scheme="secondary"
                      icon="ion-edit"
                      class-names="grey-btn"
                      @click="openEditPopup(group)"
                    >
                      {{ $t('GROUP_MGMT.EDIT.BUTTON_TEXT') }}
                    </woot-button>
                    <woot-button
                      v-if="showDeleteAction(group)"
                      variant="link"
                      color-scheme="secondary"
                      icon="ion-close-circled"
                      class-names="grey-btn"
                      @click="openDeletePopup(group, index)"
                    >
                      {{ $t('GROUP_MGMT.DELETE.BUTTON_TEXT') }}
                    </woot-button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- Add Group -->
    <woot-modal :show.sync="showAddPopup" :on-close="hideAddPopup">
      <add-group :on-close="hideAddPopup" />
    </woot-modal>
    <!-- Edit Group -->
    <woot-modal :show.sync="showEditPopup" :on-close="hideEditPopup">
      <edit-group
        v-if="showEditPopup"
        :id="currentGroup.id"
        :name="currentGroup.name"
        :users="currentGroup.users"
        :on-close="hideEditPopup"
      />
    </woot-modal>
    <!-- Delete Group -->
    <woot-delete-modal
      :show.sync="showDeletePopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="$t('GROUP_MGMT.DELETE.CONFIRM.TITLE')"
      :message="deleteMessage"
      :confirm-text="deleteConfirmText"
      :reject-text="deleteRejectText"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import globalConfigMixin from 'shared/mixins/globalConfigMixin';
import AddGroup from './AddGroup.vue';
import EditGroup from './EditGroup';
import store from 'dashboard/store';

export default {
  components: {
    AddGroup,
    EditGroup
  },
  mixins: [globalConfigMixin],
  data() {
    return {
      loading: {},
      showAddPopup: false,
      showDeletePopup: false,
      showEditPopup: false,
      groupAPI: {
        message: '',
      },
      currentGroup: {},
    };
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
  computed: {
    ...mapGetters({
      groupState: 'adGroups/getState',
      userState: 'adUsers/getState',
    }),
    deleteConfirmText() {
      return `${this.$t('GROUP_MGMT.DELETE.CONFIRM.YES')} ${
        this.currentGroup.name
      }`;
    },
    deleteRejectText() {
      return `${this.$t('GROUP_MGMT.DELETE.CONFIRM.NO')} ${
        this.currentGroup.name
      }`;
    },
    deleteMessage() {
      return `${this.$t('GROUP_MGMT.DELETE.CONFIRM.MESSAGE')} ${
        this.currentGroup.name
      } ?`;
    },
  },
  methods: {
    showEditAction(group) {
      return this.currentGroupId !== group.id;
    },
    showDeleteAction(group) {
      if (this.currentGroupId === group.id) {
        return false;
      }

      if (!group.confirmed) {
        return true;
      }

      if (group.role === 'administrator') {
        return this.verifiedAdministrators().length !== 1;
      }
      return true;
    },
    verifiedAdministrators() {
      return this.groupList.filter(
        group => group.role === 'administrator' && group.confirmed
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
    openEditPopup(group) {
      this.showEditPopup = true;
      this.currentGroup = group;
    },
    hideEditPopup() {
      this.showEditPopup = false;
    },

    // Delete Function
    openDeletePopup(group) {
      this.showDeletePopup = true;
      this.currentGroup = group;
    },
    closeDeletePopup() {
      this.showDeletePopup = false;
    },
    confirmDeletion() {
      this.loading[this.currentGroup.id] = true;
      this.closeDeletePopup();
      this.deleteGroup(this.currentGroup.id);
    },
    async deleteGroup(id) {
      try {
        this.$store.dispatch('adGroups/delete', id).then(() => {
          this.$store.dispatch('adGroups/get').then(() => {
            this.$store.dispatch('global/setMsg', `Deleted "${temp}" group..`)
          })
        })
        this.showAlert(this.$t('GROUP_MGMT.DELETE.API.SUCCESS_MESSAGE'));
      } catch (error) {
        this.showAlert(this.$t('GROUP_MGMT.DELETE.API.ERROR_MESSAGE'));
      }
    },
    // Show SnackBar
    showAlert(message) {
      // Reset loading, current selected group
      this.loading[this.currentGroup.id] = false;
      this.currentGroup = {};
      // Show message
      this.groupAPI.message = message;
      bus.$emit('newToastMessage', message);
    },
  },
};
</script>
