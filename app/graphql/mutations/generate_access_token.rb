# frozen_string_literal: true

module Mutations
  class GenerateAccessToken < BaseMutation
    argument :username, String, required: true
    argument :password, String, required: true

    field :access_token, String, null: true
    field :user, Types::UserType, null: true

    def execute(username:, password:)
      result = Accrue::Users::GenerateToken.call!(username: username, password: password)

      {
        access_token: result.token,
        user: result.user
      }
    end
  end
end
