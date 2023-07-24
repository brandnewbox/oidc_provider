# frozen_string_literal: true

module OIDCProvider
  class IdToken < ApplicationRecord
    PASSPHRASE_ENV_VAR = 'OIDC_PROVIDER_KEY_PASSPHRASE'

    belongs_to :authorization

    attribute :expires_at, :datetime, default: -> { 1.hour.from_now }

    delegate :account, to: :authorization

    def to_response_object
      OpenIDConnect::ResponseObject::IdToken.new(id_token_attributes)
    end

    def to_jwt
      to_response_object.to_jwt(self.class.private_jwk)
    end

    private

    # Return a Struct accepting all the possible attributes from an instance of
    # the OpenIDConnect::ResponseObject::IdToken class used to collect the scope
    # values and populate the OpenIDConnect::ResponseObject::IdToken instance
    # that will be returned by the above `to_response_object`.
    #
    # At first I used an OpenStruct but since it has been officially discouraged
    # for performance, version compatibility, and potential security issues,
    # a `Struct` with predefined attributes is used instead.
    # See https://docs.ruby-lang.org/en/3.0/OpenStruct.html#class-OpenStruct-label-Caveats
    def build_id_token_struct
      Struct.new(*OpenIDConnect::ResponseObject::IdToken.all_attributes)
    end

    def build_user_info_struct
      Struct.new(*OpenIDConnect::ResponseObject::UserInfo.all_attributes)
    end

    def build_values_from_scope(scope_config)
      attributes, context = prepare_response_object_builder_from(scope_config)

      ResponseObjectBuilder.new(attributes, context, scope_config.requested_claims)
                           .run(&scope_config.scope.work)

      response_attributes = attributes.to_h.compact

      scope_config.force_claim.each do |key, value|
        response_attributes[key] = value
      end

      response_attributes
    end

    def id_token_attributes
      scope_configs.each_with_object({}) do |scope_config, memo|
        output = build_values_from_scope(scope_config)
        memo.merge!(output)
      end
    end

    def prepare_response_object_builder_from(scope_config)
      if scope_config.name == OIDCProvider::Scopes::OpenID
        [build_id_token_struct.new, self]
      else
        [build_user_info_struct.new, account]
      end
    end

    def scope_configs
      authorization.scope_configs_for(:id_token)
    end

    class << self
      def config
        {
          issuer: OIDCProvider.issuer,
          jwk_set: JSON::JWK::Set.new(public_jwk)
        }
      end

      def oidc_provider_key_path
        Rails.root.join("lib/oidc_provider_key.pem")
      end

      def key_pair
        @key_pair ||= OpenSSL::PKey::RSA.new(File.read(oidc_provider_key_path), ENV[PASSPHRASE_ENV_VAR])
      end

      def private_jwk
        JSON::JWK.new key_pair
      end

      def public_jwk
        JSON::JWK.new key_pair.public_key
      end
    end
  end
end
