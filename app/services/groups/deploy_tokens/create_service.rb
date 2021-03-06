# frozen_string_literal: true

module Groups
  module DeployTokens
    class CreateService < BaseService
      include DeployTokenMethods

      def execute
        deploy_token = create_deploy_token_for(@group, params)

        if deploy_token.persisted?
          success(deploy_token: deploy_token, http_status: :ok)
        else
          error(deploy_token.errors.full_messages.to_sentence, :bad_request)
        end
      end
    end
  end
end
