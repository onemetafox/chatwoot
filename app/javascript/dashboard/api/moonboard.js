import ApiClient from './ApiClient';

class MoonboardAPI extends ApiClient {
  constructor() {
    super('moonboards', { accountScoped: true });
  }

  getItems({ moonboardId }) {
    return axios.get(`${this.url}/${moonboardId}/moonboard_items`);
  }

  addItems({ moonboardId, itemsList }) {
    return axios.post(`${this.url}/${moonboardId}/moonboard_items`, {
      item_ids: itemsList,
    });
  }

  updateItems({ moonboardId, itemsList }) {
    return axios.patch(`${this.url}/${moonboardId}/moonboard_items`, {
      item_ids: itemsList,
    });
  }

  download(moonboardId) {
    return axios.post(`${this.url}/${moonboardId}/download`);
  }
}

export default new MoonboardAPI();
