# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accrue::Users::GenerateToken, type: :interactor do
  describe '.call' do
    let(:user) { create(:user, username: 'testuser', password: 'password123') }

    context 'with valid credentials' do
      before { user }

      it 'succeeds' do
        result = described_class.call(username: 'testuser', password: 'password123')

        expect(result).to be_success
      end

      it 'sets the user in context' do
        result = described_class.call(username: 'testuser', password: 'password123')

        expect(result.user).to eq(user)
      end

      it 'generates a token' do
        result = described_class.call(username: 'testuser', password: 'password123')

        expect(result.token).to be_present
        decoded = TokenEncoder.decode(result.token)
        expect(decoded['user_id']).to eq(user.id)
      end
    end

    context 'with invalid username' do
      it 'fails with unauthorized error' do
        result = described_class.call(username: 'invalid', password: 'password123')

        expect(result).to be_failure
        expect(result.error[:type]).to eq(ErrorTypes::UNAUTHORIZED)
        expect(result.error[:message]).to eq('Invalid username or password')
      end
    end

    context 'with invalid password' do
      before { user }

      it 'fails with unauthorized error' do
        result = described_class.call(username: 'testuser', password: 'wrongpassword')

        expect(result).to be_failure
        expect(result.error[:type]).to eq(ErrorTypes::UNAUTHORIZED)
        expect(result.error[:message]).to eq('Invalid username or password')
      end
    end
  end
end
