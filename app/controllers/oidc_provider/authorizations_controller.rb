# frozen_string_literal: true

module OIDCProvider
  class AuthorizationsController < ApplicationController
    include Concerns::ConnectEndpoint

    before_action :require_oauth_request
    before_action :require_response_type_code
    before_action :ensure_claims_is_valid
    before_action :require_client
    before_action :reset_login_if_necessary
    before_action :require_authentication

    def create
      authorization = build_authorization

      oauth_response.code = authorization.code
      oauth_response.redirect_uri = @redirect_uri
      oauth_response.approve!
      redirect_to oauth_response.location

      # If we ever need to support denied authorizations that is done by:
      # oauth_request.access_denied!
    end

    private

    def build_authorization
      authorization = Authorization.new(
        client_id: @client.identifier,
        nonce: oauth_request.nonce,
        scopes: requested_scopes,
        account: oidc_current_account
      )

      authorization.claims = JSON.parse(oauth_request.claims) if oauth_request.claims

      authorization.save
      authorization
    end

    def ensure_claims_is_valid
      return true unless oauth_request.claims

      validate_json_is_a_hash!(parse_claims_as_json!)
    rescue Errors::InvalidClaimsFormatError => error
      Rails.logger.error "Invalid claims passed: #{error.message}"
      oauth_request.invalid_request! 'invalid claims format'
    end

    def parse_claims_as_json!
      JSON.parse(oauth_request.claims)
    rescue JSON::ParserError => error
      Rails.logger.error "Invalid claims passed: #{error.message}"
      oauth_request.invalid_request! 'claims just be a JSON'
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

    # Recursive method validating the given `json` is a hash of hashes
    def validate_json_is_a_hash!(json)
      # When reaching the end of the json/hash path, we're getting a `nil`, or
      # a String (hard coded value) or the `essential` boolean value (not yet
      # implemented).
      #
      # For example, when the previous call of this method received
      # `{ email: nil }`, the current call of this method receives `nil`.
      return if json.nil? || json.is_a?(String)

      raise Errors::InvalidClaimsFormatError unless json.is_a?(Hash)

      json.each_key { |key| validate_json_is_a_hash!(json[key]) }
    end
  end
end
