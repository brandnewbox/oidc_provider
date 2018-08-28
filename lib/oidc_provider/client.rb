module OIDCProvider
  class Client
    attr_accessor :identifier, :secret, :redirect_uri, :name

    def initialize(options = {})
      @identifier = options[:identifier]
      @secret = options[:secret]
      @redirect_uri = options[:redirect_uri]
      @name = options[:name]
    end
  end
end

require 'oidc_provider/client/builder'