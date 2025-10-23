FactoryBot.define do
  factory :access_token, class: 'Doorkeeper::AccessToken' do
    association :application, factory: :oauth_application
    association :resource_owner, factory: :user
    expires_in { 1.hour }
    scopes { 'read write' }
    use_refresh_token { true }
  end
end
