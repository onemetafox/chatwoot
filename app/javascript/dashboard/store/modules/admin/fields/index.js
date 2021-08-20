import getters from './getters.js'
import mutations from './mutations.js'
import actions from './actions.js'

const state = {
  categories: {
    Account: [],
    Campaign: [],
    Contact: [],
    Lead: [],
    Opportunity: []
  },
  selectCatename: null,
  ceGroupID: null,
  ceFieldData: {},
};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
  getters
};