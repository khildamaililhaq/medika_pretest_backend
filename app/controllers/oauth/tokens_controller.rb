class Oauth::TokensController < ApplicationController
  before_action :application
  
  def issue
    user = User.authenticate!(params[:email], params[:password])
    return render json: { error: "invalid_grant", error_description: "Invalid credentials" }, status: :unauthorized unless user

    access_token = Doorkeeper::AccessToken.create!(
      application_id: @application.id,
      resource_owner_id: user.id,
      scopes: "read write",
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: true
    )

    render json: {
      access_token: access_token.token,
      token_type: "Bearer",
      expires_in: access_token.expires_in,
      refresh_token: access_token.refresh_token,
      scope: access_token.scopes.to_s,
      created_at: access_token.created_at.to_i
    }, status: :ok
  end

  def refresh
    old_token = Doorkeeper::AccessToken.find_by(refresh_token: params[:refresh_token])

    return render json: { error: "invalid_grant", error_description: "Invalid refresh token" }, status: :bad_request unless old_token

    # Create new access token
    new_token = Doorkeeper::AccessToken.create!(
      application_id: @application.id,
      resource_owner_id: old_token.resource_owner_id,
      scopes: old_token.scopes,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: true
    )

    # Optionally revoke old token
    old_token.revoke

    render json: {
      access_token: new_token.token,
      token_type: "Bearer",
      expires_in: new_token.expires_in,
      refresh_token: new_token.refresh_token,
      scope: new_token.scopes.to_s,
      created_at: new_token.created_at.to_i
    }, status: :ok
  end

  def revoke
    # Revoke token logic - use Doorkeeper's standard revoke endpoint
    response = Doorkeeper::OAuth::TokenRequest.new(
      Doorkeeper.configuration,
      nil,
      params
    ).revoke

    render json: response.body, status: response.status
  end

  private
  def application
    @application ||= Doorkeeper::Application.find_by(uid: params[:client_id])

    render json: { error: "invalid_client", error_description: "Client not found" }, status: :unauthorized unless @application
  end
end
