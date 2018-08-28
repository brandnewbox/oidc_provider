module OIDCProvider
  class TokenEndpoint
    attr_accessor :app
    delegate :call, to: :app

    def initialize
      @app = Rack::OAuth2::Server::Token.new do |req, res|
        Rails.logger.info "Client ID: #{req.client_id}"
        Rails.logger.info "Client secret: #{req.client_secret}"
        Rails.logger.info "Redirect URI: #{req.redirect_uri}"
        client = ClientStore.new.find_by(
          identifier: req.client_id,
          secret: req.client_secret,
          redirect_uri: req.redirect_uri
        ) || req.invalid_client!
        
        Rails.logger.info "Found a client!"

        case req.grant_type
        when :authorization_code
          Rails.logger.info "Grant type was an authorization code. Correct!"
          authorization = Authorization.valid.where(client_id: client.identifier, code: req.code).first || req.invalid_grant!
          Rails.logger.info "We found an authorization matching this code!"
          res.access_token = authorization.access_token.to_bearer_token
          res.id_token = authorization.id_token.to_jwt if authorization.scopes.include?("openid")
        else
          Rails.logger.info "Unsupported grant type"
          req.unsupported_grant_type!
        end
      end
    end
  end
end