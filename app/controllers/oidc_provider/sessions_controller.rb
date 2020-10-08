module OIDCProvider
  class SessionsController < ApplicationController
    before_filter :require_authentication

    def destroy
      unauthenticate!
      redirect_to root_url
    end
  end
end