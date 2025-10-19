class Category < ApplicationRecord
  include Ransackable

  validates :name, presence: true, uniqueness: true
end
