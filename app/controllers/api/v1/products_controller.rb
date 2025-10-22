module Api
  module V1
    class ProductsController < ApplicationController
      before_action :doorkeeper_authorize!
      before_action :set_product, only: %i[ show update destroy ]

      # GET /products
      def index
        @products = Product.ransack(params[:q]).result.page(params[:page]).per(params[:per_page] || 10)

        generate_collection_serializer(@products, ProductSerializer)
      end

      # GET /products/1
      def show
        render json: ProductSerializer.new(@product)
      end

      # POST /products
      def create
        @product = Product.new(product_params)

        if @product.save
          render json: ProductSerializer.new(@product), status: :created
        else
          render json: @product.errors, status: :unprocessable_content
        end
      end

      # PATCH/PUT /products/1
      def update
        if @product.update(product_params)
          render json: ProductSerializer.new(@product)
        else
          render json: @product.errors, status: :unprocessable_content
        end
      end

      # DELETE /products/1
      def destroy
        @product.destroy!
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_product
          @product = Product.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def product_params
          params.require(:product).permit(:name, :publish, :category_id)
        end
    end
  end
end
