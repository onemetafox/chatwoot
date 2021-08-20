import types from '../../mutation-types'

const mutations = {
  [types.SET_ERROR](state, error) {
    state.error = error
  },
  [types.SET_MSG](state, msg) {
    state.msg = msg
  },
};

export default mutations;
