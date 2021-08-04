import PostHome from './Index';
import { frontendURL } from '../../../../helper/URLHelper';

export default {
  routes: [
    {
      name: 'post_form',
      path: frontendURL('accounts/:accountId/dashboard/posts'),
      component: PostHome,
      roles: ['administrator', 'agent'],
      props: {
        headerTitle: 'Post Schedule',
        icon: 'ion-share',
        showNewButton: false,
      },
    },
  ],
};
