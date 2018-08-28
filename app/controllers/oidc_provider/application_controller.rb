module OIDCProvider
  class ApplicationController < ActionController::Base
    include Concerns::Authentication
  end
end
