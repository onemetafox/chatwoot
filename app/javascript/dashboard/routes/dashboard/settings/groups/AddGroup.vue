<template>
  <woot-modal :show.sync="show" :on-close="onClose">
    <div class="column content-box">
      <woot-modal-header
        :header-title="$t('GROUP_MGMT.ADD.TITLE')"
        :header-content="$t('GROUP_MGMT.ADD.DESC')"
      />

      <form class="row" @submit.prevent="addGroup()">
        <div class="medium-12 columns">
          <label :class="{ error: $v.groupName.$error }">
            {{ $t('GROUP_MGMT.ADD.FORM.NAME.LABEL') }}
            <input
              v-model.trim="groupName"
              type="text"
              :placeholder="$t('GROUP_MGMT.ADD.FORM.NAME.PLACEHOLDER')"
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
        <div class="modal-footer">
          <div class="medium-12 columns">
            <woot-submit-button
              :disabled=" $v.groupName.$invalid"
              :button-text="$t('GROUP_MGMT.ADD.FORM.SUBMIT')"
            />
            <button class="button clear" @click.prevent="onClose">
              {{ $t('GROUP_MGMT.ADD.CANCEL_BUTTON_TEXT') }}
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
    group: {
      type: Object,
      default: () => {}
    },
    users: {
      type: Array,
      default: () => []
    },
    onClose: {
      type: Function,
      default: () => {},
    },
  },
  data() {
    return {
      groupName: '',
      id: '',
      vertical: 'bottom',
      horizontal: 'center',
      ins: [],
      name: null,
      roles: [
        {
          name: 'administrator',
          label: this.$t('GROUP_MGMT.GROUP_TYPES.ADMINISTRATOR'),
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
    groupName: {
      required,
      minLength: minLength(1),
    }
  },

  methods: {
    showAlert(message) {
      bus.$emit('newToastMessage', message);
    },
    async addGroup() {
      try {
        let formData = new FormData()
        formData.append('name', this.groupName)
        await this.$store.dispatch('adGroups/update', { id: this.id, formData}).then(() => {
          this.$store.dispatch('adGroups/get').then(() => {})
        });
        this.showAlert(this.$t('GROUP_MGMT.ADD.API.SUCCESS_MESSAGE'));
        this.onClose();
      } catch (error) {
        if (error.response.status === 422) {
          this.showAlert(this.$t('GROUP_MGMT.ADD.API.EXIST_MESSAGE'));
        } else {
          this.showAlert(this.$t('GROUP_MGMT.ADD.API.ERROR_MESSAGE'));
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