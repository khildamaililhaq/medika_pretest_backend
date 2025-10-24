require 'swagger_helper'

RSpec.describe 'Api::V1::Products', type: :request do
  let(:user) { create(:user) }
  let(:application) { create(:oauth_application) }
  let(:access_token) do
    create(:access_token,
           resource_owner_id: user.id,
           application_id: application.id,
           scopes: 'read write')
  end
  let(:Authorization) { "Bearer #{access_token.token}" }
  path '/api/v1/products' do
    get 'List products' do
      tags 'Products'
      produces 'application/json'
      security [ Bearer: {} ]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'

      # Fix: Use proper parameter definition for Ransack
      parameter name: 'q[name_cont]', in: :query, type: :string, required: false,
                description: 'Search products where name contains the given string'
      parameter name: 'q[publish_eq]', in: :query, type: :boolean, required: false,
                description: 'Filter products by publish status (true/false)'
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
                       category: { type: :object, properties: {
                         id: { type: :string, format: :uuid },
                         name: { type: :string }
                       } },
                       category_id: { type: :string, format: :uuid },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' }
                     },
                     required: %w[id name publish category_id created_at updated_at]
                   }
                 }
               }

        let!(:product) { create(:product) }
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
                       category_id: { type: :string, format: :uuid },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' }
                     },
                     required: %w[id name publish category_id created_at updated_at]
                   }
                 }
               }

        let!(:product1) { create(:product, name: 'Testing Product', publish: true) }
        # let!(:product2) { create(:product, name: 'Another Product', publish: true) }
        let(:page) { 1 }
        let(:per_page) { 10 }
        let(:'q[name_cont]') { 'Test' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['data'].length).to eq(1)
          expect(data['data'].first['name']).to eq('Testing Product')
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
                       category: { type: :object, properties: {
                         id: { type: :string, format: :uuid },
                         name: { type: :string }
                       } },
                       category_id: { type: :string, format: :uuid },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' }
                     },
                     required: %w[id name publish category_id created_at updated_at]
                   }
                 }
               }

        let!(:product1) { create(:product, name: 'Pub Product', publish: true) }
        let(:page) { 1 }
        let(:per_page) { 10 }
        let(:'q[publish_eq]') { false }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['data'].length).to eq(0)
          expect(data['meta']['total_data']).to eq(0)
        end
      end
    end

    post 'Create product' do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: {} ]

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              publish: { type: :boolean },
              category_id: { type: :string, format: :uuid }
            },
            required: %w[name]
          }
        },
        required: %w[product]
      }

      response '201', 'product created' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 name: { type: :string },
                 publish: { type: :boolean },
                 category_id: { type: :string, format: :uuid },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name publish category_id created_at updated_at]

        let(:product) do
          {
            product: {
              name: 'Test Product',
              publish: true,
              category_id: create(:category).id
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

        let(:product) do
          {
            product: {
              name: ''
            }
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:product) do
          {
            product: {
              name: 'Test Product'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/products/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid, description: 'Product ID'

    get 'Show product' do
      tags 'Products'
      produces 'application/json'
      security [ Bearer: {} ]

      response '200', 'successful' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 name: { type: :string },
                 publish: { type: :boolean },
                 category: { type: :object, properties: {
                         id: { type: :string, format: :uuid },
                         name: { type: :string }
                       } },
                 category_id: { type: :string, format: :uuid },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name publish category_id created_at updated_at]

        let(:id) { create(:product).id }

        run_test!
      end

      response '404', 'not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { create(:product).id }

        run_test!
      end
    end

    patch 'Update product' do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: {} ]

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              publish: { type: :boolean },
              category_id: { type: :string, format: :uuid }
            }
          }
        },
        required: %w[product]
      }

      response '200', 'product updated' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 name: { type: :string },
                 publish: { type: :boolean },
                 category_id: { type: :string, format: :uuid },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name publish category_id created_at updated_at]

        let(:id) { create(:product).id }
        let(:product) do
          {
            product: {
              name: 'Updated Product',
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

        let(:id) { create(:product).id }
        let(:product) do
          {
            product: {
              name: ''
            }
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { create(:product).id }
        let(:product) do
          {
            product: {
              name: 'Updated Product'
            }
          }
        end

        run_test!
      end

      response '404', 'not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
        let(:product) { { product: { name: 'Test' } } }

        run_test!
      end
    end

    put 'Update product' do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: {} ]

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              publish: { type: :boolean },
              category_id: { type: :string, format: :uuid }
            },
            required: %w[name]
          }
        },
        required: %w[product]
      }

      response '200', 'product updated' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 name: { type: :string },
                 publish: { type: :boolean },
                 category_id: { type: :string, format: :uuid },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name publish category_id created_at updated_at]

        let(:id) { create(:product).id }
        let(:product) do
          {
            product: {
              name: 'Updated Product',
              publish: true
            }
          }
        end

        run_test!
      end
    end

    delete 'Delete product' do
      tags 'Products'
      security [ Bearer: {} ]

      response '204', 'no content' do
        let(:id) { create(:product).id }

        run_test!
      end

      response '404', 'not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { create(:product).id }

        run_test!
      end
    end
  end

  path '/api/v1/products/export' do
    get 'Export products to Excel' do
      tags 'Products'
      produces 'application/vnd.ms-excel'
      security [ Bearer: {} ]

      parameter name: 'q[name_cont]', in: :query, type: :string, required: false,
                description: 'Search products where name contains the given string'
      parameter name: 'q[publish_eq]', in: :query, type: :boolean, required: false,
                description: 'Filter products by publish status (true/false)'
      parameter name: 'q[created_at_gteq]', in: :query, type: :string, format: 'date-time', required: false,
                description: 'Filter products created after or on this date (greater than or equal)'
      parameter name: 'q[created_at_lteq]', in: :query, type: :string, format: 'date-time', required: false,
                description: 'Filter products created before or on this date (less than or equal)'
      parameter name: 'q[s]', in: :query, type: :string, required: false,
                description: 'Sort results (name asc, name desc, created_at desc, etc.)'

      response '200', 'successful' do
        let!(:product) { create(:product) }

        run_test! do |response|
          expect(response.content_type).to eq('application/vnd.ms-excel')
          expect(response.headers['Content-Disposition']).to include('attachment; filename="products_')
          expect(response.headers['Content-Disposition']).to include('.xls"')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end
end
