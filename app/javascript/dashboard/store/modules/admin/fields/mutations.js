import types from '../../../mutation-types'

const mutations = {
  [types.admin.fields.selectCatename](state, catename) {
    state.selectCatename = catename
  },
  [types.admin.fields.setCEGroupID](state, id) {
    state.ceGroupID = id
  },
  [types.admin.fields.setCEFieldData](state, data) {
    if (data.add) {
      if (state.ceFieldData[data.gid]) {
        let key = Object.keys(data.add)
        state.ceFieldData[data.gid][key[0]] = Object.values(data.add)[0]
      } else Object.assign(state.ceFieldData, {[data.gid]: data.add})
    } else if (data.del) {
      delete state.ceFieldData[data.gid][data.del]
      if (!Object.keys(state.ceFieldData[data.gid]).length) delete state.ceFieldData[data.gid]
    }
  },
  [types.admin.fields.setCategories](state, {catename, data}) {
    state.categories[catename] = data
  },
};

export default mutations;