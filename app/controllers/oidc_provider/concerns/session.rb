module OIDCProvider
  module Concerns
    module Sessions
      def after_oidc_sign_out_path
        "/"
      end
    end
  end
end