import axios from 'axios';
import { actions } from '../../moonboards/actions';
import {
  SET_MOONBOARD_UI_FLAG,
  CLEAR_MOONBOARD,
  SET_MOONBOARD,
  SET_MOONBOARD_ITEM,
  EDIT_MOONBOARD,
  DELETE_MOONBOARD,
} from '../../moonboards/types';
import moonboardsList from './fixtures';

const commit = jest.fn();
global.axios = axios;
jest.mock('axios');

describe('#actions', () => {
  describe('#get', () => {
    it('sends correct actions if API is success', async () => {
      axios.get.mockResolvedValue({ data: moonboardsList[1] });
      await actions.get({ commit });
      expect(commit.mock.calls).toEqual([
        [SET_MOONBOARD_UI_FLAG, { isFetching: true }],
        [CLEAR_MOONBOARD],
        [SET_MOONBOARD, moonboardsList[1]],
        [SET_MOONBOARD_UI_FLAG, { isFetching: false }],
      ]);
    });
    it('sends correct actions if API is error', async () => {
      axios.get.mockRejectedValue({ message: 'Incorrect header' });
      await expect(actions.get({ commit })).rejects.toThrow(Error);
      expect(commit.mock.calls).toEqual([
        [SET_MOONBOARD_UI_FLAG, { isFetching: true }],
        [SET_MOONBOARD_UI_FLAG, { isFetching: false }],
      ]);
    });
  });

  describe('#create', () => {
    it('sends correct actions if API is success', async () => {
      axios.post.mockResolvedValue({ data: moonboardsList[1] });
      await actions.create({ commit }, moonboardsList[1]);

      expect(commit.mock.calls).toEqual([
        [SET_MOONBOARD_UI_FLAG, { isCreating: true }],
        [SET_MOONBOARD_ITEM, moonboardsList[1]],
        [SET_MOONBOARD_UI_FLAG, { isCreating: false }],
      ]);
    });
    it('sends correct actions if API is error', async () => {
      axios.post.mockRejectedValue({ message: 'Incorrect header' });
      await expect(actions.create({ commit })).rejects.toThrow(Error);

      expect(commit.mock.calls).toEqual([
        [SET_MOONBOARD_UI_FLAG, { isCreating: true }],
        [SET_MOONBOARD_UI_FLAG, { isCreating: false }],
      ]);
    });
  });

  describe('#update', () => {
    it('sends correct actions if API is success', async () => {
      axios.patch.mockResolvedValue({ data: moonboardsList[1] });
      await actions.update({ commit }, moonboardsList[1]);

      expect(commit.mock.calls).toEqual([
        [SET_MOONBOARD_UI_FLAG, { isUpdating: true }],
        [EDIT_MOONBOARD, moonboardsList[1]],
        [SET_MOONBOARD_UI_FLAG, { isUpdating: false }],
      ]);
    });
    it('sends correct actions if API is error', async () => {
      axios.patch.mockRejectedValue({ message: 'Incorrect header' });
      await expect(actions.update({ commit }, moonboardsList[1])).rejects.toThrow(
        Error
      );
      expect(commit.mock.calls).toEqual([
        [SET_MOONBOARD_UI_FLAG, { isUpdating: true }],
        [SET_MOONBOARD_UI_FLAG, { isUpdating: false }],
      ]);
    });
  });

  describe('#delete', () => {
    it('sends correct actions if API is success', async () => {
      axios.delete.mockResolvedValue();
      await actions.delete({ commit }, 1);
      expect(commit.mock.calls).toEqual([
        [SET_MOONBOARD_UI_FLAG, { isDeleting: true }],
        [DELETE_MOONBOARD, 1],
        [SET_MOONBOARD_UI_FLAG, { isDeleting: false }],
      ]);
    });
    it('sends correct actions if API is error', async () => {
      axios.delete.mockRejectedValue({ message: 'Incorrect header' });
      await expect(actions.delete({ commit }, 1)).rejects.toThrow(Error);
      expect(commit.mock.calls).toEqual([
        [SET_MOONBOARD_UI_FLAG, { isDeleting: true }],
        [SET_MOONBOARD_UI_FLAG, { isDeleting: false }],
      ]);
    });
  });
});
