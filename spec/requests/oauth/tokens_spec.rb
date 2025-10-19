require 'rails_helper'

RSpec.describe "Oauth::Tokens", type: :request do
  path '/oauth/token/issue' do
    post 'Issue Token' do
      tags 'Authentication'
      consumes 'application/x-www-form-urlencoded'
      produces 'application/json'

      parameter name: :grant_type, in: :formData, type: :string, required: true, enum: [ 'password' ]
      parameter name: :email, in: :formData, type: :string, required: true
      parameter name: :password, in: :formData, type: :string, required: true
      parameter name: :client_id, in: :formData, type: :string, required: true, default: Doorkeeper::Application.first&.uid
      parameter name: :client_secret, in: :formData, type: :string, required: true, default: Doorkeeper::Application.first&.secret

      response '200', 'token issued' do
        schema type: :object,
               properties: {
                 access_token: { type: :string },
                 token_type: { type: :string, enum: [ 'Bearer' ] },
                 expires_in: { type: :integer },
                 refresh_token: { type: :string },
                 scope: { type: :string },
                 created_at: { type: :integer }
               }

        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) do
          create(:access_token,
                 resource_owner_id: user.id,
                 application_id: application.id,
                 scopes: 'read write')
        end

        let(:grant_type) { 'password' }
        let(:email) { user.email }
        let(:password) { user.password }
        let(:client_id) { application.uid }
        let(:client_secret) { application.secret }

        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string },
                 error_description: { type: :string }
               }

        let(:grant_type) { 'password' }
        let(:email) { 'invalid@example.com' }
        let(:password) { 'wrongpassword' }
        let(:client_id) { 'invalid_client_id' }
        let(:client_secret) { 'invalid_client_secret' }

        run_test!
      end
    end
  end

  path '/oauth/revoke' do
      post 'Revoke Token' do
        tags 'Authentication'
        consumes 'application/x-www-form-urlencoded'
        produces 'application/json'

        parameter name: :token, in: :formData, type: :string, required: true
        parameter name: :client_id, in: :formData, type: :string, required: false, default: Doorkeeper::Application.first&.uid
        parameter name: :client_secret, in: :formData, type: :string, required: false, default: Doorkeeper::Application.first&.secret

        response '200', 'token revoked' do
          schema type: :object,
                 properties: {}

          let(:user) { create(:user) }
          let(:application) { create(:oauth_application) }
          let(:access_token) do
            create(:access_token,
                   resource_owner_id: user.id,
                   application_id: application.id,
                   scopes: 'read write')
          end

          let(:token) { access_token.token }
          let(:client_id) { application.uid }
          let(:client_secret) { application.secret }

          run_test!
        end

        response '403', 'forbidden' do
          schema type: :object,
                 properties: {
                   error: { type: :string },
                   error_description: { type: :string }
                 }

          let(:token) { 'invalid_token' }

          run_test!
        end
      end
    end

  path '/oauth/token/refresh' do
    post 'Refresh Token' do
      tags 'Authentication'
      consumes 'application/x-www-form-urlencoded'
      produces 'application/json'

      parameter name: :grant_type, in: :formData, type: :string, required: true, enum: [ 'refresh_token' ]
      parameter name: :refresh_token, in: :formData, type: :string, required: true
      parameter name: :client_id, in: :formData, type: :string, required: true, default: Doorkeeper::Application.first&.uid
      parameter name: :client_secret, in: :formData, type: :string, required: true, default: Doorkeeper::Application.first&.secret

      response '200', 'token refreshed' do
        schema type: :object,
               properties: {
                 access_token: { type: :string },
                 token_type: { type: :string, enum: [ 'Bearer' ] },
                 expires_in: { type: :integer },
                 refresh_token: { type: :string },
                 scope: { type: :string },
                 created_at: { type: :integer }
               }

        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) do
          create(:access_token,
                 resource_owner_id: user.id,
                 application_id: application.id,
                 scopes: 'read write')
        end

        let(:grant_type) { 'refresh_token' }
        let(:refresh_token) { access_token.refresh_token }
        let(:client_id) { application.uid }
        let(:client_secret) { application.secret }

        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string },
                 error_description: { type: :string }
               }

        let(:grant_type) { 'refresh_token' }
        let(:refresh_token) { 'invalid_refresh_token' }
        let(:client_id) { 'invalid_client_id' }
        let(:client_secret) { 'invalid_client_secret' }

        run_test!
      end
    end
  end
end
