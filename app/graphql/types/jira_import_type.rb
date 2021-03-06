# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  # Authorization is at project level for owners or admins,
  # so it is added directly to the Resolvers::JiraImportsResolver
  class JiraImportType < BaseObject
    graphql_name 'JiraImport'

    field :scheduled_at, Types::TimeType, null: true,
          description: 'Timestamp of when the Jira import was created/started'
    field :scheduled_by, Types::UserType, null: true,
          description: 'User that started the Jira import'
    field :jira_project_key, GraphQL::STRING_TYPE, null: false,
          description: 'Project key for the imported Jira project',
          method: :key

    def scheduled_at
      DateTime.parse(object.scheduled_at)
    end

    def scheduled_by
      ::Gitlab::Graphql::Loaders::BatchModelLoader.new(User, object.scheduled_by['user_id']).find
    end
  end
  # rubocop: enable Graphql/AuthorizeTypes
end
