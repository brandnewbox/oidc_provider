module OIDCProvider
  class SessionsController < ApplicationController
    before_action :require_authentication

    def destroy
      unauthenticate!
      redirect_to "/" unless OIDCProvider.after_sign_out_path
      redirect_to OIDCProvider.after_sign_out_path.respond_to?(:call) ? OIDCProvider.after_sign_out_path.call(params) : OIDCProvider.after_sign_out_path
    end
  end
end