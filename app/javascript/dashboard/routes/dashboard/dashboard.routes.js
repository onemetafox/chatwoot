import AppContainer from './Dashboard';
import settings from './settings/settings.routes';
import conversation from './conversation/conversation.routes';
import admin from './admin/admin.routes';
import { routes as contactRoutes } from './contacts/routes';
import { routes as notificationRoutes } from './notifications/routes';
import { routes as leadsRoutes } from './leads/routes';
import { frontendURL } from '../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:account_id'),
      component: AppContainer,
      children: [
        ...conversation.routes,
        ...settings.routes,
        ...admin.routes,
        ...leadsRoutes,
        ...contactRoutes,
        ...notificationRoutes,
      ],
    },
  ],
};
