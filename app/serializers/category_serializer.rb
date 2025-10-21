class CategorySerializer < ActiveModel::Serializer
  type :category

  attributes :id, :name, :publish, :created_at, :updated_at
end
