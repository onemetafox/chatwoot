require 'rails_helper'

RSpec.describe 'Moonboards API', type: :request do
  let(:account) { create(:account) }
  let!(:moonboard) { create(:moonboard, account: account) }

  describe 'GET /api/v1/accounts/{account.id}/moonboards' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get "/api/v1/accounts/#{account.id}/moonboards"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      let(:agent) { create(:user, account: account, role: :agent) }

      it 'returns all the moonboards' do
        get "/api/v1/accounts/#{account.id}/moonboards",
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).first['id']).to eq(account.moonboards.first.id)
      end
    end
  end

  describe 'GET /api/v1/accounts/{account.id}/moonboards/{moonboard_id}' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get "/api/v1/accounts/#{account.id}/moonboards/#{moonboard.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      let(:agent) { create(:user, account: account, role: :agent) }

      it 'returns all the moonboards' do
        get "/api/v1/accounts/#{account.id}/moonboards/#{moonboard.id}",
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['id']).to eq(moonboard.id)
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/moonboards' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post "/api/v1/accounts/#{account.id}/moonboards"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      let(:agent) { create(:user, account: account, role: :agent) }
      let(:administrator) { create(:user, account: account, role: :administrator) }

      it 'returns unathorized for agent' do
        params = { name: 'Test Moonboard' }

        post "/api/v1/accounts/#{account.id}/moonboards",
             params: params,
             headers: agent.create_new_auth_token,
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'creates a new moonboard when its administrator' do
        params = { name: 'test-moonboard' }

        post "/api/v1/accounts/#{account.id}/moonboards",
             params: params,
             headers: administrator.create_new_auth_token,
             as: :json

        expect(response).to have_http_status(:success)
        expect(moonboard.count).to eq(2)
      end
    end
  end

  describe 'PUT /api/v1/accounts/{account.id}/moonboards/:id' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        put "/api/v1/accounts/#{account.id}/moonboards/#{moonboard.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      let(:agent) { create(:user, account: account, role: :agent) }
      let(:administrator) { create(:user, account: account, role: :administrator) }

      it 'returns unauthorized for agent' do
        params = { name: 'new-moonboard' }

        put "/api/v1/accounts/#{account.id}/moonboards/#{moonboard.id}",
            params: params,
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'updates an existing moonboard when its an administrator' do
        params = { name: 'new-moonboard' }

        put "/api/v1/accounts/#{account.id}/moonboards/#{moonboard.id}",
            params: params,
            headers: administrator.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        expect(moonboard.reload.name).to eq('new-moonboard')
      end
    end
  end

  describe 'DELETE /api/v1/accounts/{account.id}/moonboards/:id' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        delete "/api/v1/accounts/#{account.id}/moonboards/#{moonboard.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      let(:agent) { create(:user, account: account, role: :agent) }
      let(:administrator) { create(:user, account: account, role: :administrator) }

      it 'return unauthorized for agent' do
        delete "/api/v1/accounts/#{account.id}/moonboards/#{moonboard.id}",
               headers: agent.create_new_auth_token,
               as: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'destroys the moonboard when its administrator' do
        delete "/api/v1/accounts/#{account.id}/moonboards/#{moonboard.id}",
               headers: administrator.create_new_auth_token,
               as: :json

        expect(response).to have_http_status(:success)
        expect(Moonboard.count).to eq(0)
      end
    end
  end
end
