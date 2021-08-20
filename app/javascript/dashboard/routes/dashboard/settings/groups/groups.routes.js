import SettingsContent from '../Wrapper';
import GroupsHome from './Index';
import { frontendURL } from '../../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/groups'),
      component: SettingsContent,
      props: {
        headerTitle: 'GROUP_MGMT.HEADER',
        icon: 'ion-person-stalker',
        showNewButton: false,
      },
      children: [
        {
          path: '',
          name: 'groups_wrapper',
          redirect: 'list',
        },
        {
          path: 'list',
          name: 'group_list',
          component: GroupsHome,
          roles: ['administrator'],
        },
      ],
    },
  ],
};
