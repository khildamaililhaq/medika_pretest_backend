FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    publish { false }
    association :category
  end
end
