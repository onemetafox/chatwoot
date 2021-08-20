import types from '../../../mutation-types'

const mutations = {
  [types.admin.groups.editID](state, editID) {
    state.editID = editID
  },
  [types.admin.groups.get](state, groups) {
    state.groups = groups
  },
};

export default mutations;