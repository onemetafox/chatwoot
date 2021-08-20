import SettingsContent from '../Wrapper';
import TagsHome from './Index';
import { frontendURL } from '../../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/tags'),
      component: SettingsContent,
      props: {
        headerTitle: 'TAG_MGMT.HEADER',
        icon: 'ion-person-stalker',
        showNewButton: false,
      },
      children: [
        {
          path: '',
          name: 'tags_wrapper',
          redirect: 'list',
        },
        {
          path: 'list',
          name: 'tag_list',
          component: TagsHome,
          roles: ['administrator'],
        },
      ],
    },
  ],
};
