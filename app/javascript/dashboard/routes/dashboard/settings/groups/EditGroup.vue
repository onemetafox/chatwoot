 <template>
  <modal :show.sync="show" :on-close="onClose">
    <div class="column content-box">
      <woot-modal-header :header-title="pageTitle" />
      <form class="row medium-8" @submit.prevent="editGroup()">
        <div class="medium-12 columns">
          <label :class="{ error: $v.groupName.$error }">
            {{ $t('GROUP_MGMT.EDIT.FORM.NAME.LABEL') }}
            <input
              v-model.trim="groupName"
              type="text"
              :placeholder="$t('GROUP_MGMT.EDIT.FORM.NAME.PLACEHOLDER')"
              @input="$v.groupName.$touch"
            />
          </label>
        </div>
        <div class="medium-12 columns">
          <label>
            {{ $t('GROUP_MGMT.ADD.FORM.NAME.LABEL') }}
            <multiselect ref="g_select" v-model="ins"
              placeholder="Search user"
              label="username" track-by="id"
              :multiple="true" :taggable="true"
              :options="users"
            />
          </label>
        </div>

        <div class="medium-12 modal-footer">
          <div class="medium-6 columns">
            <woot-submit-button
              :disabled="$v.groupName.$invalid "
              :button-text="$t('GROUP_MGMT.EDIT.FORM.SUBMIT')"
            />
            <button class="button clear" @click.prevent="onClose">
              {{ $t('GROUP_MGMT.EDIT.CANCEL_BUTTON_TEXT') }}
            </button>
          </div>
        </div>
      </form>
    </div>
  </modal>
</template>

<script>
import { required, minLength } from 'vuelidate/lib/validators';
import { mapGetters } from 'vuex';
import WootSubmitButton from 'dashboard/components/buttons/FormSubmitButton';
import Modal from 'dashboard/components/Modal';
import Auth from 'dashboard/api/auth';

export default {
  components: {
    WootSubmitButton,
    Modal,
  },
  props: {
    id: {
      type: Number,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    onClose: {
      type: Function,
      required: true,
    },
  },
  data() {
    return {
      roles: [
        {
          name: 'administrator',
          label: this.$t('GROUP_MGMT.GROUP_TYPES.ADMINISTRATOR'),
        }
      ],
      groupName: this.name,
      show: true,
    };
  },
  validations: {
    groupName: {
      required,
      minLength: minLength(1),
    }
  },
  computed: {
    pageTitle() {
      return `${this.$t('GROUP_MGMT.EDIT.TITLE')} - ${this.name}`;
    },
    ...mapGetters({
    }),
  },
  methods: {
    showAlert(message) {
      bus.$emit('newToastMessage', message);
    },
    async editGroup() {
      try {
        let formData = new FormData()
        formData.append('name', this.groupName)
        await this.$store.dispatch('adGroups/update', { id: this.id, formData}).then(() => {
          this.$store.dispatch('adGroups/get').then(() => {})
        });;
        this.showAlert(this.$t('GROUP_MGMT.EDIT.API.SUCCESS_MESSAGE'));
        this.onClose();
      } catch (error) {
        this.showAlert(this.$t('GROUP_MGMT.EDIT.API.ERROR_MESSAGE'));
      }
    },
    async resetPassword() {
      try {
        await Auth.resetPassword(this.groupCredentials);
        this.showAlert(
          this.$t('GROUP_MGMT.EDIT.PASSWORD_RESET.ADMIN_SUCCESS_MESSAGE')
        );
      } catch (error) {
        this.showAlert(this.$t('GROUP_MGMT.EDIT.PASSWORD_RESET.ERROR_MESSAGE'));
      }
    },
  },
};
</script>
<style lang="scss" scoped>
  label {
    width: 100%;
  }
</style>
