import {
    CLEAR_MOONBOARD,
    SET_MOONBOARD,
    SET_MOONBOARD_ITEM,
    EDIT_MOONBOARD,
    DELETE_MOONBOARD,
  } from '../../moonboards/types';
  import { mutations } from '../../moonboards/mutations';
  import moonboards from './fixtures';
  describe('#mutations', () => {
    describe('#SET_MOONBOARD', () => {
      it('set moonboards records', () => {
        const state = { records: {} };
        mutations[SET_MOONBOARD](state, [moonboards[1]]);
        mutations[SET_MOONBOARD](state, [moonboards[2]]);
        expect(state.records).toEqual(moonboards);
      });
    });
  
    describe('#ADD_TEAM', () => {
      it('push newly created moonboards to the store', () => {
        const state = { records: {} };
        mutations[SET_MOONBOARD_ITEM](state, moonboards[1]);
        expect(state.records).toEqual({ 1: moonboards[1] });
      });
    });
  
    describe('#EDIT_MOONBOARD', () => {
      it('update moonboards record', () => {
        const state = { records: [moonboards[1]] };
        mutations[EDIT_MOONBOARD](state, {
          id: 1,
          title: 'customer-support',
        });
        expect(state.records[1].title).toEqual('customer-support');
      });
    });
  
    describe('#DELETE_MOONBOARD', () => {
      it('delete moonboards record', () => {
        const state = { records: { 1: moonboards[1] } };
        mutations[DELETE_MOONBOARD](state, 1);
        expect(state.records).toEqual({});
      });
    });
  
    describe('#CLEAR_MOONBOARD', () => {
      it('delete moonboards record', () => {
        const state = { records: { 1: moonboards[1] } };
        mutations[CLEAR_MOONBOARD](state);
        expect(state.records).toEqual({});
      });
    });
  });
  