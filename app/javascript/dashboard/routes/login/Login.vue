<template>
  <div class="medium-12 column login">
    <md-card class="login-page md-card-login">
      <md-card-header class="md-card-header-green">
        <div>
          <img
            :src="globalConfig.logo"
            :alt="globalConfig.installationName"
            class="hero__logo"
          />
        </div>
      </md-card-header>
      <md-card-content>
        <ValidationObserver v-slot="{ handleSubmit }" ref="login_form_obs">
          <form ref="login_form" @submit.prevent="handleSubmit(submit)">
            <div class="md-layout create-field-group mt-3">
              <div class="md-layout-item md-medium-size-100 md-xsmall-size-100 md-size-100">
                <ValidationProvider
                  name="email"
                  rules="required|email"
                  v-slot="{passed, failed}"
                >
                  <md-field class="md-form-group" :class="[{ 'md-error': failed }, { 'md-valid': passed }]">
                    <b-icon :icon="passed? 'person-check-fill' : 'person-fill'" 
                      :variant="passed ? 'success' : 'danger'" scale="3" />
                    <label>{{ $t('LOGIN.EMAIL.LABEL') }}</label>
                    <md-input name="email" v-model="credentials.email" type="email" />
                  </md-field>
                </ValidationProvider>
              </div>
              <div class="md-layout-item md-medium-size-100 md-xsmall-size-100 md-size-100">
                <ValidationProvider
                  name="password"
                  rules="required|min:3"
                  v-slot="{ passed, failed }"
                >
                  <md-field class="md-form-group" :class="[{ 'md-error': failed }, { 'md-valid': passed }]">
                    <b-icon :icon="passed ? 'unlock-fill' : 'lock-fill'" 
                      :variant="passed ? 'success' : 'danger'" scale="3" />
                    <label>{{ $t('LOGIN.PASSWORD.LABEL') }}</label>
                    <md-input v-model="credentials.password" type="password" />
                  </md-field>
                </ValidationProvider>
              </div>
              <div class="md-layout-item md-medium-size-100 md-xsmall-size-100 md-size-100" v-if="showForgot()">
                <md-checkbox v-model="forgot" slot="check" @change="forgotPwd">
                  {{ $t('LOGIN.FORGOT_PASSWORD') }}
                </md-checkbox>
              </div>
              <div class="md-layout-item md-medium-size-100 md-xsmall-size-100 md-size-100">
                <md-progress-bar md-mode="indeterminate" v-if="sending" />
              </div>
              <div class="md-layout-item md-medium-size-100 md-xsmall-size-100 md-size-100">
                <md-button type="submit" class="md-success w-100" :disabled="disabledSubmit()">
                  {{$t('LOGIN.SUBMIT')}}
                </md-button>
              </div>
            </div>
          </form>
        </ValidationObserver>
      </md-card-content>
    </md-card>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { extend } from "vee-validate";
import { email, required, min } from "vee-validate/dist/rules";
import Auth from '../../api/auth';

extend("email", email);
extend("required", required);
extend("min", min);


export default {
  props: {
    ssoAuthToken: { type: String, default: null },
    config: { type: String, default: null },
    email: { type: String, default: null },
  },
  data() {
    return {
      forgot: false,
      sending: false,
      credentials: {
        email: null,
        password: null,
      },
    };
  },
  computed: {
    ...mapGetters({
      globalConfig: 'globalConfig/get',
    }),
  },
  created() {
    if (this.$props.ssoAuthToken) this.credentials.email = JSON.stringify(this.$props.email)
  },
  methods: {
    showAlert(message) {
      this.sending = false
      bus.$emit('newToastMessage', message);
    },
    init() {
      this.forgot = false
      this.sending = false
    },
    disabledSubmit() {
      return !this.sending && this.$refs.login_form_obs?.fields?.email.valid && this.$refs.login_form_obs?.fields?.password.valid ? false : true
    },
    submit() {
      this.sending = true;
      const credentials = {
        email: this.credentials.email,
        password: this.credentials.password,
        sso_auth_token: this.$props.ssoAuthToken,
      };
      this.$store.dispatch('login', credentials)
        .then(() => {
          this.showAlert(this.$t('LOGIN.API.SUCCESS_MESSAGE'));

        })
        .catch(err => {
          if (err && err.status === 401) {
						const { errors } = err.data;
						const hasAuthErrorMsg = errors && errors.length && errors[0] && typeof errors[0] === 'string';
            if (hasAuthErrorMsg) this.showAlert(errors[0]);
            else this.showAlert(this.$t('LOGIN.API.UNAUTH'));
          } else this.showAlert(this.$t('LOGIN.API.ERROR_MESSAGE'));
        });
    },
    showForgot() {
      let show = this.$refs.login_form_obs?.fields?.email.valid
      if (!show) this.forgot = false;
      return show
    },
    forgotPwd(checked) {
      if (checked && this.$refs.login_form_obs.fields.email.valid) {
        this.sending = true;
        Auth.resetPassword(this.credentials)
        .then(res => {
          let successMessage = this.$t('RESET_PASSWORD.API.SUCCESS_MESSAGE');
          if (res.data && res.data.message) {
            successMessage = res.data.message;
          }
          this.showAlert(successMessage);
          this.forgot = false
        })
        .catch(error => {
          let errorMessage = this.$t('RESET_PASSWORD.API.ERROR_MESSAGE');
          if (error?.response?.data?.message) errorMessage = error.response.data.message;
          this.showAlert(errorMessage);
          this.forgot = false
        });
      }
    },
  },
};
</script>
<style scoped lang="scss">
  .md-field label {
    left: 36px;
  }
  .md-field .md-input, .md-field .md-textarea {
    margin-bottom: 0;
    margin-left: 30px;
    padding: 7px;
  }
</style>
