class ProductSerializer < ActiveModel::Serializer
  type :product

  attributes :id, :name, :publish, :category_id, :created_at, :updated_at, :category
end
