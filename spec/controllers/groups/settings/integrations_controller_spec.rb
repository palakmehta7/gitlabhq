# frozen_string_literal: true

require 'spec_helper'

describe Groups::Settings::IntegrationsController do
  let_it_be(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  before do
    sign_in(user)
  end

  describe '#edit' do
    context 'when group_level_integrations not enabled' do
      it 'returns not_found' do
        stub_feature_flags(group_level_integrations: { enabled: false, thing: group })

        get :edit, params: { group_id: group, id: Service.available_services_names.sample }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is not owner' do
      it 'renders not_found' do
        get :edit, params: { group_id: group, id: Service.available_services_names.sample }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is owner' do
      before do
        group.add_owner(user)
      end

      Service.available_services_names.each do |integration_name|
        context "#{integration_name}" do
          it 'successfully displays the template' do
            get :edit, params: { group_id: group, id: integration_name }

            expect(response).to have_gitlab_http_status(:ok)
            expect(response).to render_template(:edit)
          end
        end
      end
    end
  end

  describe '#update' do
    let(:integration) { create(:jira_service, project: project) }

    before do
      group.add_owner(user)

      put :update, params: { group_id: group, id: integration.class.to_param, service: { url: url } }
    end

    context 'valid params' do
      let(:url) { 'https://jira.gitlab-example.com' }

      it 'updates the integration' do
        expect(response).to have_gitlab_http_status(:found)
        expect(integration.reload.url).to eq(url)
      end
    end

    context 'invalid params' do
      let(:url) { 'ftp://jira.localhost' }

      it 'does not update the integration' do
        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:edit)
        expect(integration.reload.url).not_to eq(url)
      end
    end
  end

  describe '#test' do
    context 'testable' do
      let(:integration) { create(:jira_service, project: project) }

      before do
        group.add_owner(user)
      end

      it 'returns ok' do
        allow_any_instance_of(integration.class).to receive(:test) { { success: true } }

        put :test, params: { group_id: group, id: integration.class.to_param }

        expect(response).to have_gitlab_http_status(:ok)
      end
    end

    context 'not testable' do
      let(:integration) { create(:alerts_service, project: project) }

      it 'returns not found' do
        put :test, params: { group_id: group, id: integration.class.to_param }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
