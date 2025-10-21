require 'swagger_helper'

RSpec.describe 'Api::V1::Categories', type: :request do
  let(:user) { create(:user) }
  let(:application) { create(:oauth_application) }
  let(:access_token) do
    create(:access_token,
           resource_owner_id: user.id,
           application_id: application.id,
           scopes: 'read write')
  end
  let(:Authorization) { "Bearer #{access_token.token}" }

  path '/api/v1/categories' do
    get 'List categories' do
      tags 'Categories'
      produces 'application/json'
      security [ Bearer: {} ]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'

      # Fix: Use proper parameter definition for Ransack
      parameter name: 'q[name_cont]', in: :query, type: :string, required: false,
                description: 'Search categories where name contains the given string'
      parameter name: 'q[publish_eq]', in: :query, type: :boolean, required: false,
                description: 'Filter categories by publish status (true/false)'
      parameter name: 'q[s]', in: :query, type: :string, required: false,
                description: 'Sort results (name asc, name desc, created_at desc, etc.)'

      response '200', 'successful' do
        schema type: :object,
               properties: {
                 meta: {
                   type: :object,
                   properties: {
                     per_page: { type: :integer },
                     current_page: { type: :integer },
                     next_page: { type: :integer, nullable: true },
                     prev_page: { type: :integer, nullable: true },
                     total_page: { type: :integer },
                     total_data: { type: :integer }
                   }
                 },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string, format: :uuid },
                       name: { type: :string },
                       publish: { type: :boolean },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' }
                     },
                     required: %w[id name publish created_at updated_at]
                   }
                 }
               }

        let!(:category) { create(:category) }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test!
      end

      response '200', 'successful with name search' do
        schema type: :object,
               properties: {
                 meta: {
                   type: :object,
                   properties: {
                     per_page: { type: :integer },
                     current_page: { type: :integer },
                     next_page: { type: :integer, nullable: true },
                     prev_page: { type: :integer, nullable: true },
                     total_page: { type: :integer },
                     total_data: { type: :integer }
                   }
                 },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string, format: :uuid },
                       name: { type: :string },
                       publish: { type: :boolean },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' }
                     },
                     required: %w[id name publish created_at updated_at]
                   }
                 }
               }

        let!(:category1) { create(:category, name: 'Test Category', publish: true) }
        let!(:category2) { create(:category, name: 'Another Category', publish: false) }
        let(:page) { 1 }
        let(:per_page) { 10 }
        let(:'q[name_cont]') { 'Test' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
        end
      end

      response '200', 'successful with publish filter' do
        schema type: :object,
               properties: {
                 meta: {
                   type: :object,
                   properties: {
                     per_page: { type: :integer },
                     current_page: { type: :integer },
                     next_page: { type: :integer, nullable: true },
                     prev_page: { type: :integer, nullable: true },
                     total_page: { type: :integer },
                     total_data: { type: :integer }
                   }
                 },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string, format: :uuid },
                       name: { type: :string },
                       publish: { type: :boolean },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' }
                     },
                     required: %w[id name publish created_at updated_at]
                   }
                 }
               }

        let!(:category1) { create(:category, name: 'Published Category', publish: true) }
        let!(:category2) { create(:category, name: 'Unpublished Category', publish: false) }
        let(:page) { 1 }
        let(:per_page) { 10 }
        let(:'q[publish_eq]') { true }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
        end
      end
    end

    post 'Create category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: {} ]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string },
              publish: { type: :boolean }
            },
            required: %w[name]
          }
        },
        required: %w[category]
      }

      response '201', 'category created' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 name: { type: :string },
                 publish: { type: :boolean },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name publish created_at updated_at]

        let(:category) do
          {
            category: {
              name: 'Test Category',
              publish: true
            }
          }
        end

        run_test!
      end

      response '422', 'unprocessable entity' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   properties: {
                     name: { type: :array, items: { type: :string } }
                   }
                 }
               }

        let(:category) do
          {
            category: {
              name: ''
            }
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:category) do
          {
            category: {
              name: 'Test Category'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/categories/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, description: 'Category ID'

    get 'Show category' do
      tags 'Categories'
      produces 'application/json'
      security [ Bearer: {} ]

      response '200', 'successful' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 name: { type: :string },
                 publish: { type: :boolean },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name publish created_at updated_at]

        let(:id) { create(:category).id }

        run_test!
      end

      response '404', 'not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { create(:category).id }

        run_test!
      end
    end

    patch 'Update category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: {} ]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string },
              publish: { type: :boolean }
            }
          }
        },
        required: %w[category]
      }

      response '200', 'category updated' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 name: { type: :string },
                 publish: { type: :boolean },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name publish created_at updated_at]

        let(:id) { create(:category).id }
        let(:category) do
          {
            category: {
              name: 'Updated Category',
              publish: true
            }
          }
        end

        run_test!
      end

      response '422', 'unprocessable entity' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   properties: {
                     name: { type: :array, items: { type: :string } }
                   }
                 }
               }

        let(:id) { create(:category).id }
        let(:category) do
          {
            category: {
              name: ''
            }
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { create(:category).id }
        let(:category) do
          {
            category: {
              name: 'Updated Category'
            }
          }
        end

        run_test!
      end

      response '404', 'not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
        let(:category) { { category: { name: 'Test' } } }

        run_test!
      end
    end

    put 'Update category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: {} ]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string },
              publish: { type: :boolean }
            },
            required: %w[name]
          }
        },
        required: %w[category]
      }

      response '200', 'category updated' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 name: { type: :string },
                 publish: { type: :boolean },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name publish created_at updated_at]

        let(:id) { create(:category).id }
        let(:category) do
          {
            category: {
              name: 'Updated Category',
              publish: true
            }
          }
        end

        run_test!
      end
    end

    delete 'Delete category' do
      tags 'Categories'
      security [ Bearer: {} ]

      response '204', 'no content' do
        let(:id) { create(:category).id }

        run_test!
      end

      response '404', 'not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { create(:category).id }

        run_test!
      end
    end
  end
end
