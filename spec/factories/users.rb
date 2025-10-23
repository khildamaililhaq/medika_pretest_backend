FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'P@ssword123!' }
    password_confirmation { 'P@ssword123!' }
  end
end
