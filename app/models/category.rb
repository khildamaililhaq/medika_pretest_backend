class Category < ApplicationRecord
  include Ransackable

  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
