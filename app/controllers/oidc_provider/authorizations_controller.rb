module OIDCProvider
  class AuthorizationsController < ApplicationController
    include Concerns::ConnectEndpoint

    before_action :require_oauth_request
    before_action :require_response_type_code
    before_action :require_client
    before_action :require_authentication

    def create
      puts "scopes: #{requested_scopes}"
      authorization = Authorization.create(
        client_id: @client.identifier,
        nonce: oauth_request.nonce,
        scopes: requested_scopes,
        account: oidc_current_account
      )

      oauth_response.code = authorization.code
      oauth_response.redirect_uri = @redirect_uri
      oauth_response.approve!
      redirect_to oauth_response.location

      # If we ever need to support denied authorizations that is done by:
      # oauth_request.access_denied!
    end

    private

    def require_client
      @client = ClientStore.new.find_by(identifier: oauth_request.client_id) or oauth_request.invalid_request! 'not a valid client'
      @redirect_uri = oauth_request.verify_redirect_uri! [oauth_request.redirect_uri, @client.redirect_uri]
    end

    def requested_scopes
      @requested_scopes ||= (["openid"] + OIDCProvider.supported_scopes.map(&:name)) & oauth_request.scope
    end
    helper_method :requested_scopes

    def require_response_type_code
      unless oauth_request.response_type == :code
        oauth_request.unsupported_response_type!
      end
    end
  end

end