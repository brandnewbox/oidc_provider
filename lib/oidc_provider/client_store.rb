module OIDCProvider
  class ClientStore
    attr_reader :clients

    def initialize(clients = OIDCProvider.clients)
      @clients = clients
    end

    def find_by(attrs)
      clients.detect { |client| attrs.all? { |key, value| client.send(key) == value } }
    end
  end
end