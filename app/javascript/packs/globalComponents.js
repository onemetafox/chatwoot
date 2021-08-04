import { ValidationProvider } from "vee-validate";
import { ValidationObserver } from "vee-validate";
import Multiselect from 'vue-multiselect';
/**
 * You can register global components here and use them as a plugin in your main Vue instance
 */

const GlobalComponents = {
  install(Vue) {
    Vue.component("ValidationProvider", ValidationProvider);
    Vue.component("ValidationObserver", ValidationObserver);
    Vue.component('multiselect', Multiselect);
  }
};

export default GlobalComponents;
