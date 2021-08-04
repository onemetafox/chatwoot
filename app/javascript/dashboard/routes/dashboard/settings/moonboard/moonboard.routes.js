/* eslint arrow-body-style: 0 */
import SettingsContent from '../Wrapper';
import Index from './Index';
import CreateStepWrap from './Create/Index';
import CreateBoard from './Create/Create';
import AddItems from './Create/AddItems';
import EditStepWrap from './Edit/Index';
import EditBoard from './Edit/EditBoard';
import EditItems from './Edit/EditItems';
import { frontendURL } from '../../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/moonboards'),
      component: SettingsContent,
      props: params => {
        const showBackButton = params.name !== 'moonboards_list';
        return {
          headerTitle: 'MOONBOARD_SETTINGS.HEADER',
          headerButtonText: 'MOONBOARD_SETTINGS.NEW',
          icon: 'ion-ios-dashboard',
          newButtonRoutes: ['moonboard_new'],
          showBackButton,
        };
      },
      children: [
        {
          path: '',
          name: 'moonboards',
          redirect: 'list',
        },
        {
          path: 'list',
          name: 'moonboards_list',
          component: Index,
          roles: ['administrator'],
        },
        {
          path: 'new',
          component: CreateStepWrap,
          children: [
            {
              path: '',
              name: 'moonboards_new',
              component: CreateBoard,
              roles: ['administrator'],
            },
            {
              path: ':moonboardId/items',
              name: 'moonboards_add_items',
              component: AddItems,
              roles: ['administrator'],
            }
          ],
        },
        {
          path: ':moonboardId/edit',
          component: EditStepWrap,
          children: [
            {
              path: '',
              name: 'moonboards_edit',
              component: EditBoard,
              roles: ['administrator'],
            },
            {
              path: 'items',
              name: 'moonboards_edit_items',
              component: EditItems,
              roles: ['administrator'],
            }
          ],
        },
      ],
    },
  ],
};
