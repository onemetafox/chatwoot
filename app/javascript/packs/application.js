/* eslint no-console: 0 */
/* eslint-env browser */
/* eslint-disable no-new */
/* Vue Core */

import Vue from 'vue';
import VueI18n from 'vue-i18n';
import VueRouter from 'vue-router';
import axios from 'axios';
import hljs from 'highlight.js';
import Multiselect from 'vue-multiselect';
import VueFormulate from '@braid/vue-formulate';
import { ModalPlugin } from 'bootstrap-vue'
import { sync } from 'vuex-router-sync';
import Vuelidate from 'vuelidate';
import VTooltip from 'v-tooltip';
import * as Sentry from '@sentry/vue';
import { Integrations } from '@sentry/tracing';

import App from '../dashboard/App';
import WootUiKit from '../dashboard/components';
import i18n from '../dashboard/i18n';
import createAxios from '../dashboard/helper/APIHelper';
import commonHelpers, { isJSONValid } from '../dashboard/helper/commons';
import router from '../dashboard/routes';
import store from '../dashboard/store';
import vueActionCable from '../dashboard/helper/actionCable';
import constants from '../dashboard/constants';
import {
  verifyServiceWorkerExistence,
  registerSubscription,
} from '../dashboard/helper/pushHelper';
import WootSwitch from 'components/ui/Switch';
import WootWizard from 'components/ui/Wizard';

import MdPlugin from './material-ui.js'

Vue.config.env = process.env;

if (window.errorLoggingConfig) {
  Sentry.init({
    Vue,
    dsn: window.errorLoggingConfig,
    integrations: [new Integrations.BrowserTracing()],
  });
}

Vue.use(VueRouter);
Vue.use(VueI18n);
Vue.use(Vuelidate);
Vue.use(VueFormulate, {
  rules: {
    JSON: ({ value }) => isJSONValid(value),
  },
});
Vue.use(VTooltip, {
  defaultHtml: false,
});
Vue.use(hljs.vuePlugin);
Vue.use(ModalPlugin);
Vue.use(WootUiKit);
Vue.use(MdPlugin);

Vue.component('multiselect', Multiselect);
Vue.component('woot-switch', WootSwitch);
Vue.component('woot-wizard', WootWizard);

const i18nConfig = new VueI18n({
  locale: 'en',
  messages: i18n,
});

sync(store, router);
// load common helpers into js
commonHelpers();

window.WootConstants = constants;
window.axios = createAxios(axios);
window.bus = new Vue();
window.onload = () => {
  window.WOOT = new Vue({
    router,
    store,
    i18n: i18nConfig,
    components: { App },
    template: '<App/>',
  }).$mount('#app');
  vueActionCable.init();
};
window.addEventListener('load', () => {
  verifyServiceWorkerExistence(registration =>
    registration.pushManager.getSubscription().then(subscription => {
      if (subscription) {
        registerSubscription();
      }
    })
  );
  getAlertAudio();
  initFaviconSwitcher();
});

window.addEventListener('load', () => {
  navigator.serviceWorker
    .register('/sw.js')
    .then(registration => {
      console.log('ServiceWorker registered: ', registration);
      var serviceWorker;
      if (registration.installing) {
        serviceWorker = registration.installing;
        console.log('Service worker installing.');
      } else if (registration.waiting) {
        serviceWorker = registration.waiting;
        console.log('Service worker installed & waiting.');
      } else if (registration.active) {
        serviceWorker = registration.active;
        console.log('Service worker active.');
      }
    })
    .catch(registrationError => {
      console.log('Service worker registration failed: ', registrationError);
    });
});
