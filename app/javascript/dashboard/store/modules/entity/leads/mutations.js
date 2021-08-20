import types from '../../../mutation-types'

const mutations = {
  [types.entity.leads.get](state, leads) {
    state.leads = leads
  },
  [types.entity.leads.getone](state, lead) {
    state.lead = lead
  },
  [types.entity.leads.query](state, query) {
    state.query = query
  },
  [types.entity.leads.queryHistory](state, track) {
    let find = state.queryHistory.find(k => k === track)
    if (!find) state.queryHistory.push(track).sort()
  },
  [types.entity.leads.editID](state, editID) {
    state.editID = editID
  },
  [types.entity.leads.editing](state, editing) {
    state.editing = editing
  },
  [types.entity.leads.page](state, page) {
    state.page = page
  },
};

export default mutations;
