/* global axios */
import ApiClient from './ApiClient';

class PostShare extends ApiClient {
  constructor() {
    super('social_media_posts', { accountScoped: false });
  }

  create(data) {
    return axios.post(this.url, data);
  }
}

export default new PostShare();
