module OIDCProvider
  class Client
    class Builder
      def initialize(&block)
        @client = Client.new
        @operation = block
      end

      def build
        instance_exec(&@operation)
        @client
      end

      [:identifier, :secret, :redirect_uri, :name].each do |attr|
        define_method attr do |val|
          @client.send("#{attr}=", val)
        end
      end
    end
  end
end