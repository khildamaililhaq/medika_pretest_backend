Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (requires ORM extensions installed).
  # Check the list of supported ORMs here: https://github.com/doorkeeper-gem/doorkeeper#orms
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    current_user || warden.authenticate!(scope: :user)
  end

  resource_owner_from_credentials do |_routes|
    User.authenticate!(params[:email], params[:password]) # we need to add this method in our user model
  end

  grant_flows %w[authorization_code client_credentials password]

  use_refresh_token

  allow_blank_redirect_uri true

  client_credentials :from_basic, :from_params

  access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  access_token_expires_in 1.hour
end
