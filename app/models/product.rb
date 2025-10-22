class Product < ApplicationRecord
  include Ransackable

  belongs_to :category

  validates :name, presence: true, uniqueness: true
end
