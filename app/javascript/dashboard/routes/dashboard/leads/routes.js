/* eslint arrow-body-style: 0 */
import LeadsView from './index.vue';
import { frontendURL } from '../../../helper/URLHelper';

export const routes = [
  {
    path: frontendURL('accounts/:accountId/entity/leads'),
    name: 'entity_leads',
    roles: ['administrator', 'agent'],
    component: LeadsView,
  },
];

