module OIDCProvider
  module Concerns
    module Authentication
      def oidc_current_account
        send(OIDCProvider.current_account_method)
      end

      def current_token
        @current_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      end

      def require_authentication
        send(OIDCProvider.current_authentication_method)
      end

      def require_access_token
        unless current_token
          raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new
        end
      end

      def unauthenticate!
        send(OIDCProvider.current_unauthenticate_method)
      end
    end
  end
end