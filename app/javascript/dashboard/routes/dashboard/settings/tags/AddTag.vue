<template>
  <woot-modal :show.sync="show" :on-close="onClose">
    <div class="column content-box">
      <woot-modal-header
        :header-title="$t('TAG_MGMT.ADD.TITLE')"
        :header-content="$t('TAG_MGMT.ADD.DESC')"
      />

      <form class="row" @submit.prevent="addTag()">
        <div class="medium-12 columns">
          <label :class="{ error: $v.tagName.$error }">
            {{ $t('TAG_MGMT.ADD.FORM.NAME.LABEL') }}
            <input
              v-model.trim="tagName"
              type="text"
              :placeholder="$t('TAG_MGMT.ADD.FORM.NAME.PLACEHOLDER')"
              @input="$v.tagName.$touch"
            />
          </label>
        </div>
        <div class="modal-footer">
          <div class="medium-12 columns">
            <woot-submit-button
              :disabled=" $v.tagName.$invalid"
              :button-text="$t('TAG_MGMT.ADD.FORM.SUBMIT')"
            />
            <button class="button clear" @click.prevent="onClose">
              {{ $t('TAG_MGMT.ADD.CANCEL_BUTTON_TEXT') }}
            </button>
          </div>
        </div>
      </form>
    </div>
  </woot-modal>
</template>

<script>
import { required, minLength, email } from 'vuelidate/lib/validators';
import { mapGetters } from 'vuex';

export default {
  props: {
    tag: {
      type: Object,
      default: () => {}
    },
    onClose: {
      type: Function,
      default: () => {},
    },
  },
  data() {
    return {
      tagName: '',
      id: '',
      vertical: 'bottom',
      horizontal: 'center',
      roles: [
        {
          name: 'administrator',
          label: this.$t('TAG_MGMT.TAG_TYPES.ADMINISTRATOR'),
        }
      ],
      show: true,
    };
  },
  computed: {
    ...mapGetters({
  }),
  },
  validations: {
    tagName: {
      required,
      minLength: minLength(1),
    }
  },

  methods: {
    showAlert(message) {
      bus.$emit('newToastMessage', message);
    },
    async addTag() {
      try {
        let formData = new FormData()
        formData.append('name', this.tagName)
        await this.$store.dispatch('adTags/update', { id: this.id, formData}).then(() => {
          this.$store.dispatch('adTags/get').then(() => {})
        });
        this.showAlert(this.$t('TAG_MGMT.ADD.API.SUCCESS_MESSAGE'));
        this.onClose();
      } catch (error) {
        if (error.response.status === 422) {
          this.showAlert(this.$t('TAG_MGMT.ADD.API.EXIST_MESSAGE'));
        } else {
          this.showAlert(this.$t('TAG_MGMT.ADD.API.ERROR_MESSAGE'));
        }
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