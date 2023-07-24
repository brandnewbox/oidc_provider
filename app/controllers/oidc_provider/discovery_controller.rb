# frozen_string_literal: true

module OIDCProvider
  class DiscoveryController < ApplicationController
    def show
      case params[:id]
      when 'webfinger'
        webfinger_discovery
      when 'openid-configuration'
        openid_configuration
      else
        render plain: 'Not found', status: :not_found
      end
    end

    private

    def webfinger_discovery
      jrd = {
        links: [{
          rel: OpenIDConnect::Discovery::Provider::Issuer::REL_VALUE,
          href: OIDCProvider.issuer
        }]
      }
      jrd[:subject] = params[:resource] if params[:resource].present?
      render json: jrd, content_type: 'application/jrd+json'
    end

    def openid_configuration
      config = OpenIDConnect::Discovery::Provider::Config::Response.new(
        authorization_endpoint: authorizations_url(host: OIDCProvider.issuer),
        claims_parameter_supported: true,
        claims_supported: OIDCProvider.supported_claims,
        end_session_endpoint: end_session_url(host: OIDCProvider.issuer),
        grant_types_supported: [:authorization_code],
        id_token_signing_alg_values_supported: [:RS256],
        issuer: OIDCProvider.issuer,
        jwks_uri: jwks_url(host: OIDCProvider.issuer),
        response_types_supported: [:code],
        scopes_supported: OIDCProvider.supported_scopes.map(&:name),
        subject_types_supported: [:public],
        token_endpoint: tokens_url(host: OIDCProvider.issuer),
        token_endpoint_auth_methods_supported: %w[client_secret_basic client_secret_post],
        userinfo_endpoint: user_info_url(host: OIDCProvider.issuer)
      )
      render json: config
    end
  end
end
