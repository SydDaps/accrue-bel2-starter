# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::GenerateAccessToken, type: :request do
  let(:user) { create(:user, username: 'testuser', password: 'password123') }

  let(:mutation) do
    <<~GQL
      mutation($username: String!, $password: String!) {
        generateAccessToken(input: {
          username: $username
          password: $password
        }) {
          accessToken
          user {
            id
            username
          }
          errors {
            type
            message
          }
        }
      }
    GQL
  end

  describe 'with valid credentials' do
    before { user }

    it 'returns an access token and user' do
      variables = {
        username: 'testuser',
        password: 'password123'
      }

      result = execute_graphql(mutation, variables: variables)
      data = graphql_response(result)['generateAccessToken']

      expect(data['errors']).to be_nil
      expect(data['accessToken']).to be_present
      expect(data['user']).to be_present
      expect(data['user']['id']).to eq(user.id.to_s)
      expect(data['user']['username']).to eq('testuser')

      decoded = TokenEncoder.decode(data['accessToken'])
      expect(decoded['user_id']).to eq(user.id)
    end
  end

  describe 'with invalid credentials' do
    context 'when username does not exist' do
      it 'returns an error' do
        variables = {
          username: 'nonexistent',
          password: 'password123'
        }

        result = execute_graphql(mutation, variables: variables)
        data = graphql_response(result)['generateAccessToken']

        expect(data['accessToken']).to be_nil
        expect(data['user']).to be_nil
        expect(data['errors']).to be_present
        expect(data['errors'].first['type']).to eq('unauthorized')
        expect(data['errors'].first['message']).to eq('Invalid username or password')
      end
    end

    context 'when password is incorrect' do
      it 'returns an error' do
        variables = {
          username: 'testuser',
          password: 'wrongpassword'
        }

        result = execute_graphql(mutation, variables: variables)
        data = graphql_response(result)['generateAccessToken']

        expect(data['accessToken']).to be_nil
        expect(data['user']).to be_nil
        expect(data['errors']).to be_present
        expect(data['errors'].first['type']).to eq('unauthorized')
        expect(data['errors'].first['message']).to eq('Invalid username or password')
      end
    end
  end
end
