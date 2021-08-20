import getters from './getters.js'
import mutations from './mutations.js'
import actions from './actions.js'

const state = {
  leads: [],
  lead: {},
  query: null,
  queryHistory: [],
  editID: -1,
  editing: false,
  page : {num: 1, size: 10}
};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
  getters
};
