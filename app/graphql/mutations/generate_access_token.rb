# frozen_string_literal: true

module Mutations
  class GenerateAccessToken < BaseMutation
    argument :username, String, required: true
    argument :password, String, required: true

    field :access_token, String, null: true
    field :user, Types::UserType, null: true

    def execute(username:, password:)
      @username = username
      @password = password

      authenticate_user
      generate_token

      {
        access_token: @token,
        user: @user
      }
    end

    private

    def authenticate_user
      @user = User.find_by(username: @username)

      unless @user&.authenticate(@password)
        raise Errors::Unauthorized, 'Invalid username or password'
      end
    end

    def generate_token
      @token = TokenEncoder.encode({ user_id: @user.id })
    end
  end
end
