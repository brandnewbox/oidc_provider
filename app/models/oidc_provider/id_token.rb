module OIDCProvider
  class IdToken < ApplicationRecord
    belongs_to :authorization

    attribute :expires_at, :datetime, default: -> { 1.hour.from_now }

    delegate :account, to: :authorization

    def to_response_object
      OpenIDConnect::ResponseObject::IdToken.new(
        iss: OIDCProvider.issuer,
        sub: account.send(OIDCProvider.account_identifier),
        aud: authorization.client_id,
        nonce: nonce,
        exp: expires_at.to_i,
        iat: created_at.to_i
      )
    end

    def to_jwt
      to_response_object.to_jwt(self.class.private_jwk)
    end

    private

    class << self
      def key_pair
        @key_pair ||= OpenSSL::PKey::RSA.new(File.read(Rails.root.join("lib/oidc_provider_key.pem")), ENV["OIDC_PROVIDER_KEY_PASSPHRASE"])
      end

      def private_jwk
        JSON::JWK.new key_pair
      end

      def public_jwk
        JSON::JWK.new key_pair.public_key
      end

      def config
        {
          issuer: OIDCProvider.issuer,
          jwk_set: JSON::JWK::Set.new(public_jwk)
        }
      end
    end
  end
end
