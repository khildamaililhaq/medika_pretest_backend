require "spreadsheet"

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

      # GET /products/export
      def export
        @products = Product.ransack(params[:q]).result

        # Create Excel file using spreadsheet gem
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet(name: "Products")

        # Add header row
        sheet.row(0).concat [ "ID", "Name", "Publish", "Category Name", "Created At", "Updated At" ]

        # Add data rows
        @products.each_with_index do |product, index|
          sheet.row(index + 1).concat [
            product.id.to_s,
            product.name,
            product.publish ? "Yes" : "No",
            product.category&.name || "",
            product.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            product.updated_at.strftime("%Y-%m-%d %H:%M:%S")
          ]
        end

        # Create temp file and write Excel data
        temp_file = Tempfile.new([ "products", ".xls" ], binmode: true)
        book.write(temp_file.path)
        temp_file.rewind

        send_data temp_file.read,
                  filename: "products_#{Time.current.strftime('%Y%m%d_%H%M%S')}.xls",
                  type: "application/vnd.ms-excel",
                  disposition: "attachment"

        temp_file.close
        temp_file.unlink
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
