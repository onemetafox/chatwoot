import types from '../../../mutation-types'

const mutations = {
  [types.admin.viewsearch](state, viewsearch) {
    state.viewsearch = viewsearch
  },
};

export default mutations;
