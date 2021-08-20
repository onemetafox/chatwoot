import types from '../../../mutation-types'

const actions = {
  viewSearch: async (context, creds) => {
    context.commit(types.admin.viewsearch, creds)
  },
};

export default actions;
