module OIDCProvider
  class SessionsController < ApplicationController
    before_action :require_authentication

    def destroy
      unauthenticate!
      if OIDCProvider.after_sign_out_method
        send(OIDCProvider.after_sign_out_method)
      else
        redirect_to "/"
      end
    end
  end
end