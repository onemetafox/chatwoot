import getters from './getters.js'
import mutations from './mutations.js'
import actions from './actions.js'

const state = {
  tags: [],
  editID: -1,
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};