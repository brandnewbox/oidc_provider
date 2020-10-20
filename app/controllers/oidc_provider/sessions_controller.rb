module OIDCProvider
  class SessionsController < ApplicationController
    before_action :require_authentication

    def destroy
      unauthenticate!
      redirect_to after_oidc_sign_out_path
    end
  end
end