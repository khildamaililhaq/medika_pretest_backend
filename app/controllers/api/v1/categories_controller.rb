module Api
  module V1
    class CategoriesController < ApplicationController
      include SerializerGenerator

      before_action :doorkeeper_authorize!
      before_action :set_category, only: %i[ show update destroy ]

      # GET /categories
      def index
        @categories = Category.ransack(params[:q]).result.page(params[:page]).per(params[:per_page] || 10)

        generate_collection_serializer(@categories, CategorySerializer)
      end

      # GET /categories/1
      def show
        render json: CategorySerializer.new(@category)
      end

      # POST /categories
      def create
        @category = Category.new(category_params)

        if @category.save
          render json: CategorySerializer.new(@category), status: :created
        else
          render json: @category.errors, status: :unprocessable_content
        end
      end

      # PATCH/PUT /categories/1
      def update
        if @category.update(category_params)
          render json: CategorySerializer.new(@category)
        else
          render json: @category.errors, status: :unprocessable_content
        end
      end

      # DELETE /categories/1
      def destroy
        @category.destroy!
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_category
          @category = Category.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def category_params
          params.require(:category).permit(:name, :publish)
        end
    end
  end
end
