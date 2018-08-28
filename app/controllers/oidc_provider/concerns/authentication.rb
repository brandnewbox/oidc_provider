module OIDCProvider
  module Concerns
    module Authentication
      def current_account
        send(OIDCProvider.current_account_method)
      end

      def current_token
        @current_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      end

      def require_authentication
        authenticate_user!
      end

      def require_access_token
        unless current_token
          raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new
        end
      end
    end
  end
end