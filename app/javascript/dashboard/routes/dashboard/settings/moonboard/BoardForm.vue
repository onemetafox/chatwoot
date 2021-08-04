<template>
  <div class="row">
    <div class="small-12 columns">
      <form class="row" @submit.prevent="handleSubmit">
        <woot-input
          v-model.trim="title"
          :class="{ error: $v.title.$error }"
          class="medium-12 columns"
          :label="$t('MOONBOARD_SETTINGS.FORM.TITLE.LABEL')"
          :placeholder="$t('MOONBOARD_SETTINGS.FORM.TITLE.PLACEHOLDER')"
          @input="$v.title.$touch"
        />
        <div class="modal-footer">
          <div class="medium-12 columns">
            <woot-submit-button
              :disabled="$v.title.$invalid || submitInProgress"
              :button-text="submitButtonText"
              :loading="submitInProgress"
            />
          </div>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import WootSubmitButton from '../../../../components/buttons/FormSubmitButton';
import validations from './helpers/validations';

export default {
  components: {
    WootSubmitButton,
  },

  props: {
    onSubmit: {
      type: Function,
      default: () => {},
    },
    submitInProgress: {
      type: Boolean,
      default: false,
    },
    formData: {
      type: Object,
      default: () => {},
    },
    submitButtonText: {
      type: String,
      default: '',
    },
  },
  data() {
    const formData = this.formData || {};
    const {
      title = ''
    } = formData;

    return {
      title
    };
  },
  validations,
  methods: {
    handleSubmit() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        return;
      }
      this.onSubmit({ 
        title: this.title
      });
    },
  },
};
</script>
