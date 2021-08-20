import types from '../../../mutation-types'

const mutations = {
  [types.admin.tags.editID](state, editID) {
    state.editID = editID
  },
  [types.admin.tags.get](state, tags) {
    state.tags = tags
  },
};

export default mutations;