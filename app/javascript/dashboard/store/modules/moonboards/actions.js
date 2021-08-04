import {
  SET_MOONBOARD_UI_FLAG,
  CLEAR_MOONBOARD,
  SET_MOONBOARD,
  SET_MOONBOARD_ITEM,
  EDIT_MOONBOARD,
  DELETE_MOONBOARD,
  DOWNLOAD_MOONBOARD
} from './types';
import MoonboardAPI from '../../../api/moonboard';

export const actions = {
  create: async ({ commit }, moonboardInfo) => {
    commit(SET_MOONBOARD_UI_FLAG, { isCreating: true });
    try {
      const response = await MoonboardAPI.create(moonboardInfo);
      const moonboard = response.data;
      commit(SET_MOONBOARD_ITEM, moonboard);
      return moonboard;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(SET_MOONBOARD_UI_FLAG, { isCreating: false });
    }
  },
  
  get: async ({ commit }) => {
    commit(SET_MOONBOARD_UI_FLAG, { isFetching: true });
    try {
      const response = await MoonboardAPI.get();
      const data = response.data;
      commit(CLEAR_MOONBOARD);
      commit(SET_MOONBOARD, data);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(SET_MOONBOARD_UI_FLAG, { isFetching: false });
    }
  },

  show: async ({ commit }, { id }) => {
    commit(SET_MOONBOARD_UI_FLAG, { isFetchingItem: true });
    try {
      const response = await MoonboardAPI.show(id);
      commit(SET_MOONBOARD_ITEM, response.data.payload);
      commit(SET_MOONBOARD_UI_FLAG, {
        isFetchingItem: false,
      });
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(SET_MOONBOARD_UI_FLAG, {
        isFetchingItem: false,
      });
    }
  },

  update: async ({ commit }, { id, ...updateObj }) => {
    commit(SET_MOONBOARD_UI_FLAG, { isUpdating: true });
    try {
      const response = await MoonboardAPI.update(id, updateObj);
      commit(EDIT_MOONBOARD, response.data);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(SET_MOONBOARD_UI_FLAG, { isUpdating: false });
    }
  },

  delete: async ({ commit }, moonboardId) => {
    commit(SET_MOONBOARD_UI_FLAG, { isDeleting: true });
    try {
      await MoonboardAPI.delete(moonboardId);
      commit(DELETE_MOONBOARD, moonboardId);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(SET_MOONBOARD_UI_FLAG, { isDeleting: false });
    }
  },

  download: async ({ commit }, moonboardId) => {
    commit(SET_MOONBOARD_UI_FLAG, { isDownload: true });
    try {
      console.log("moonboardId", moonboardId);
      const res = await MoonboardAPI.download(moonboardId);
      console.log(res);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(SET_MOONBOARD_UI_FLAG, { isDownload: false });
    }
  }
};
