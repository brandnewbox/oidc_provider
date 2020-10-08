module OIDCProvider
  class DiscoveryController < ApplicationController
    def show
      case params[:id]
      when 'webfinger'
        webfinger_discovery
      when 'openid-configuration'
        openid_configuration
      else
        render plain: "Not found", status: :not_found
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
      render json: jrd, content_type: Mime::JRD
    end

    def openid_configuration
      config = OpenIDConnect::Discovery::Provider::Config::Response.new(
        issuer: OIDCProvider.issuer,
        authorization_endpoint: authorizations_url(host: OIDCProvider.issuer),
        token_endpoint: tokens_url(host: OIDCProvider.issuer),
        userinfo_endpoint: user_info_url(host: OIDCProvider.issuer),
        end_session_endpoint: end_session_url(host: OIDCProvider.issuer),
        jwks_uri: jwks_url(host: OIDCProvider.issuer),
        scopes_supported: ["openid"] + OIDCProvider.supported_scopes.map(&:name),
        response_types_supported: [:code],
        grant_types_supported: [:authorization_code],
        subject_types_supported: [:public],
        id_token_signing_alg_values_supported: [:RS256],
        token_endpoint_auth_methods_supported: ['client_secret_basic', 'client_secret_post'],
        claims_supported: ['sub', 'iss', 'name', 'email']
      )
      render json: config
    end
  end

end