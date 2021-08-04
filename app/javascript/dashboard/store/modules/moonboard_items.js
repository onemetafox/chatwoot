import Vue from 'vue';
import MoonboardsAPI from '../../api/moonboards';

export const SET_MOONBOARD_ITEMS_UI_FLAG = 'SET_MOONBOARD_ITEMS_UI_FLAG';
export const ADD_ITEMS_TO_MOONBOARD = 'ADD_ITEMS_TO_MOONBOARD';

export const state = {
    records: {},
    uiFlags: {
        isFetching: false,
        isCreating: false,
        isUpdating: false,
        isDeleting: false,
    },
};

export const getters = {
    getUIFlags(_state) {
        return _state.uiFlags;
    },
    getMoonboardItems: $state => id => {
        return $state.records[id] || [];
    },
};

export const actions = {
    get: async ({ commit }, { moonboardId }) => {
        commit(SET_MOONBOARD_ITEMS_UI_FLAG, { isFetching: true });
        try {
            const { data } = await MoonboardsAPI.getItems({ moonboardId });
            commit(ADD_MOONBOARD_TO_MOONBOARD, { data, moonboardId });
        } catch (error) {
            throw new Error(error);
        } finally {
            commit(SET_MOONBOARD_ITEMS_UI_FLAG, { isFetching: false });
        }
    },
  create: async ({ commit }, { ItemsList, moonboardId }) => {
    commit(SET_MOONBOARD_ITEMS_UI_FLAG, { isCreating: true });
    try {
        const { data } = await MoonboardsAPI.addItems({ ItemsList, moonboardId });
        commit(ADD_MOONBOARD_TO_MOONBOARD, { moonboardId, data });
    } catch (error) {
        throw new Error(error);
    } finally {
        commit(SET_MOONBOARD_ITEMS_UI_FLAG, { isCreating: false });
    }
  },
  update: async ({ commit }, { ItemsList, moonboardId }) => {
    commit(SET_MOONBOARD_ITEMS_UI_FLAG, { isUpdating: true });
    try {
        const response = await MoonboardsAPI.updateItems({
            ItemsList,
            moonboardId,
        });
      commit(ADD_MOONBOARD_TO_MOONBOARD, response);
    } catch (error) {
        throw new Error(error);
    } finally {
        commit(SET_MOONBOARD_ITEMS_UI_FLAG, { isUpdating: false });
    }
  },
};

export const mutations = {
    [SET_MOONBOARD_ITEMS_UI_FLAG]($state, data) {
        $state.uiFlags = {
            ...$state.uiFlags,
            ...data,
        };
    },
    [ADD_ITEMS_TO_MOONBOARD]($state, { data, moonboardId }) {
            Vue.set($state.records, moonboardId, data);
    },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
