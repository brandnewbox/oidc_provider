# frozen_string_literal: true

module OIDCProvider
  class AuthorizationsController < ApplicationController
    include Concerns::ConnectEndpoint

    before_action :require_oauth_request
    before_action :require_response_type_code
    before_action :require_client
    before_action :reset_login_if_necessary
    before_action :require_authentication

    def create
      Rails.logger.info "scopes: #{requested_scopes}"

      authorization = build_authorization_with(requested_scopes)

      oauth_response.code = authorization.code
      oauth_response.redirect_uri = @redirect_uri
      oauth_response.approve!
      redirect_to oauth_response.location

      # If we ever need to support denied authorizations that is done by:
      # oauth_request.access_denied!
    end

    private

    def build_authorization_with(scopes)
      Authorization.create(
        client_id: @client.identifier,
        nonce: oauth_request.nonce,
        scopes: scopes,
        account: oidc_current_account
      )
    end

    def require_client
      @client = ClientStore.new.find_by(identifier: oauth_request.client_id) or oauth_request.invalid_request! 'not a valid client'
      @redirect_uri = oauth_request.verify_redirect_uri! @client.redirect_uri
    end

    def requested_scopes
      @requested_scopes ||= (['openid'] + OIDCProvider.supported_scopes.map(&:name)) & oauth_request.scope
    end
    helper_method :requested_scopes

    def require_response_type_code
      return if oauth_request.response_type == :code

      oauth_request.unsupported_response_type!
    end

    def reset_login_if_necessary
      if params[:prompt] == "login"
        # A `prompt=login` param means that we must prompt the user for sign in.
        # So we will forcibly sign out the user here and then redirect them so they
        # don't get redirected back to the url that contains `prompt=login`
        unauthenticate!
        redirect_to url_for(request.query_parameters.except(:prompt))
      end
    end
  end
end
