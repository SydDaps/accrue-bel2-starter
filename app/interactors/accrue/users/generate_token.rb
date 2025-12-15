# frozen_string_literal: true

module Accrue
  module Users
    class GenerateToken < ApplicationInteractor
      delegate :username, :password, :user, :token, to: :context

      def call
        authenticate_user
        generate_token
      end

      private

      def authenticate_user
        found_user = User.find_by(username: username)

        unless found_user&.authenticate(password)
          fail!(ErrorTypes::UNAUTHORIZED, 'Invalid username or password')
        end

        context.user = found_user
      end

      def generate_token
        context.token = TokenEncoder.encode({ user_id: user.id })
      end
    end
  end
end
