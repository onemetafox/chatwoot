import { getters } from '../../moonboards/getters';
import moonboardsList from './fixtures';

describe('#getters', () => {
  it('getMoonboards', () => {
    const state = {
      records: moonboardsList,
    };
    expect(getters.getMoonboards(state)).toEqual([moonboardsList[1], moonboardsList[2]]);
  });

  it('getMyMoonboards', () => {
    const state = {
      records: moonboardsList,
    };
    expect(
      getters.getMyMoonboards(state, {
        getMoonboards: [moonboardsList[1], moonboardsList[2]],
      })
    ).toEqual([moonboardsList[1]]);
  });

  it('getMoonboard', () => {
    const state = {
      records: moonboardsList,
    };
    expect(getters.getMoonboard(state)(1)).toEqual({
      id: 1,
      account_id: 1,
      title: 'Test',
    });
  });

  it('getUIFlags', () => {
    const state = {
      uiFlags: {
        isFetching: false,
        isCreating: false,
        isUpdating: false,
        isDeleting: false,
      },
    };
    expect(getters.getUIFlags(state)).toEqual({
      isFetching: false,
      isCreating: false,
      isUpdating: false,
      isDeleting: false,
    });
  });
});
