 <template>
  <modal :show.sync="show" :on-close="onClose">
    <div class="column content-box">
      <woot-modal-header :header-title="pageTitle" />
      <form class="row medium-8" @submit.prevent="editTag()">
        <div class="medium-12 columns">
          <label :class="{ error: $v.tagName.$error }">
            {{ $t('TAG_MGMT.EDIT.FORM.NAME.LABEL') }}
            <input
              v-model.trim="tagName"
              type="text"
              :placeholder="$t('TAG_MGMT.EDIT.FORM.NAME.PLACEHOLDER')"
              @input="$v.tagName.$touch"
            />
          </label>
        </div>

        <div class="medium-12 modal-footer">
          <div class="medium-6 columns">
            <woot-submit-button
              :disabled="$v.tagName.$invalid "
              :button-text="$t('TAG_MGMT.EDIT.FORM.SUBMIT')"
            />
            <button class="button clear" @click.prevent="onClose">
              {{ $t('TAG_MGMT.EDIT.CANCEL_BUTTON_TEXT') }}
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
          label: this.$t('TAG_MGMT.TAG_TYPES.ADMINISTRATOR'),
        }
      ],
      tagName: this.name,
      show: true,
    };
  },
  validations: {
    tagName: {
      required,
      minLength: minLength(1),
    }
  },
  computed: {
    pageTitle() {
      return `${this.$t('TAG_MGMT.EDIT.TITLE')} - ${this.name}`;
    },
    ...mapGetters({
    }),
  },
  methods: {
    showAlert(message) {
      bus.$emit('newToastMessage', message);
    },
    async editTag() {
      try {
        let formData = new FormData()
        formData.append('name', this.tagName)
        await this.$store.dispatch('adTags/update', { id: this.id, formData}).then(() => {
          this.$store.dispatch('adTags/get').then(() => {})
        });;
        this.showAlert(this.$t('TAG_MGMT.EDIT.API.SUCCESS_MESSAGE'));
        this.onClose();
      } catch (error) {
        this.showAlert(this.$t('TAG_MGMT.EDIT.API.ERROR_MESSAGE'));
      }
    },
    async resetPassword() {
      try {
        await Auth.resetPassword(this.tagCredentials);
        this.showAlert(
          this.$t('TAG_MGMT.EDIT.PASSWORD_RESET.ADMIN_SUCCESS_MESSAGE')
        );
      } catch (error) {
        this.showAlert(this.$t('TAG_MGMT.EDIT.PASSWORD_RESET.ERROR_MESSAGE'));
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
