require 'swagger_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  path '/api/v1/auth/register' do
    post 'Register a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, minLength: 6 },
              password_confirmation: { type: :string, minLength: 6 }
            },
            required: %w[email password password_confirmation]
          }
        },
        required: %w[user]
      }

      response '201', 'user created' do
        schema type: :object,
               properties: {
                 message: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :string, format: :uuid },
                     email: { type: :string, format: :email },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        let(:user) do
          {
            user: {
              email: 'test@example.com',
              password: 'P@ssword123',
              password_confirmation: 'P@ssword123'
            }
          }
        end

        run_test!
      end

      response '422', 'unprocessable entity' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               }

        let(:user) do
          {
            user: {
              email: 'invalid-email',
              password: '123',
              password_confirmation: '456'
            }
          }
        end

        run_test!
      end
    end
  end
end
