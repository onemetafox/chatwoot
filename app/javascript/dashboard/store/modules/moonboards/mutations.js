import Vue from 'vue';
import {
  SET_MOONBOARD_UI_FLAG,
  CLEAR_MOONBOARD,
  SET_MOONBOARD,
  SET_MOONBOARD_ITEM,
  EDIT_MOONBOARD,
  DELETE_MOONBOARD,
  DOWNLOAD_MOONBOARD,
} from './types';

export const mutations = {
  [SET_MOONBOARD_UI_FLAG]($state, data) {
    $state.uiFlags = {
      ...$state.uiFlags,
      ...data,
    };
  },

  [CLEAR_MOONBOARD]: $state => {
    Vue.set($state, 'records', {});
  },

  [SET_MOONBOARD]: ($state, data) => {
    data.forEach(moonboard => {
      Vue.set($state.records, moonboard.id, {
        ...($state.records[moonboard.id] || {}),
        ...moonboard,
      });
    });
  },

  [SET_MOONBOARD_ITEM]: ($state, data) => {
    Vue.set($state.records, data.id, {
      ...($state.records[data.id] || {}),
      ...data,
    });
  },

  [EDIT_MOONBOARD]: ($state, data) => {
    Vue.set($state.records, data.id, data);
  },

  [DELETE_MOONBOARD]: ($state, moonboardId) => {
    const { [moonboardId]: toDelete, ...records } = $state.records;
    Vue.set($state, 'records', records);
  },

  [DOWNLOAD_MOONBOARD]: ($state, moonboardId) => {
    const { [moonboardId]: toDownload, ...records } = $state.records;
    Vue.set($state, 'records', records);
  }
};
