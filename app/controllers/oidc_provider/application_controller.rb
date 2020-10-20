module OIDCProvider
  class ApplicationController < ActionController::Base
    include Concerns::Authentication
    include Concerns::Session
  end
end
