export const getters = {
  getMoonboards($state) {
    return Object.values($state.records).sort((a, b) => a.id - b.id);
  },
  getMyMoonboard($state, $getters) {
    return $getters.getMoonboards.filter(moonboard => {
      const { is_member: isMember } = moonboard;
      return isMember;
    });
  },
  getUIFlags($state) {
    return $state.uiFlags;
  },
  getMoonboard: $state => id => {
    const moonboard = $state.records[id];
    return moonboard || {};
  },
};
