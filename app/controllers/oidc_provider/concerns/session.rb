module OIDCProvider
  module Concerns
    module Session
      def after_oidc_sign_out_path
        "/"
      end
    end
  end
end