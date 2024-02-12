# frozen_string_literal: true

module OIDCProvider
  class Authorization < ApplicationRecord
    belongs_to :account, class_name: OIDCProvider.account_class
    has_one :access_token
    has_one :id_token

    scope :valid, -> { where(arel_table[:expires_at].gteq(Time.now.utc)) }

    attribute :code, :string, default: -> { SecureRandom.hex 32 }
    attribute :expires_at, :datetime, default: -> { 5.minutes.from_now }

    serialize :scopes, JSON
    serialize :claims, JSON

    def access_token
      super || (expire! && generate_access_token!)
    end

    def scope_configs_for(type)
      if claims_request_for?(type)
        build_scope_configs_from_claims_request_for(type)
      else
        type == :id_token ? [open_id_scope_config] : user_info_scope_configs
      end
    end

    def expire!
      self.expires_at = Time.now

      save!
    end

    def id_token
      super || generate_id_token!
    end

    def user_info_scopes
      scopes - ['openid']
    end

    private

    def build_scope_config_for(scope, type, key)
      ScopeConfig.new(scope, [key.to_sym]).tap do |scope_config|
        scope_config.add_force_claim(key.to_sym => claims[type.to_s][key])
      end
    end

    def build_scope_configs_from_claims_request_for(type)
      # No matter the `claims` config, when we are about to create an IdToken
      # response, we need the OpenID scope claims since there's mandatory ones
      scope_configs = type == :id_token ? [open_id_scope_config] : []

      claims[type.to_s].each_key do |key|
        scopes_with_claim = OIDCProvider.find_all_scopes_with_claim(key)

        next unless scope_found?(scopes_with_claim, key)

        warn_when_many_scopes_found_in(scopes_with_claim, key, type)

        scope = scopes_with_claim.first

        next unless scope_has_been_requested?(scope)

        scope_configs << build_scope_config_for(scope, type, key)
      end

      scope_configs
    end

    def claims_request_for?(type)
      return false unless claims

      claims.keys.include?(type.to_s)
    end

    def generate_access_token!
      create_access_token!
    end

    def generate_id_token!
      token = build_id_token
      token.nonce = nonce
      token.save!
      token
    end

    def open_id_scope_config
      scope = OIDCProvider.find_scope(OIDCProvider::Scopes::OpenID)

      ScopeConfig.new(scope, scope.claims)
    end

    def scope_found?(scopes_with_claim, key)
      return true unless scopes_with_claim.empty?

      Rails.logger.warn(
        "WARNING: No scope found providing the '#{key}' claim. " \
        'OIDCProvider will skip it.'
      )

      false
    end

    def scope_has_been_requested?(scope)
      return true if scopes.include?(scope.name)

      Rails.logger.warn(
        "WARNING: The scope #{scope.name} has not being requested " \
        'on authorization creation, there fore OIDCProvider will skip it.'
      )

      false
    end

    def user_info_scope_configs
      user_info_scopes.map do |scope_name|
        scope = OIDCProvider.find_scope(scope_name)

        ScopeConfig.new(scope, scope.claims)
      end
    end

    def warn_when_many_scopes_found_in(scopes_with_claim, key, type)
      return unless scopes_with_claim.size > 1

      Rails.logger.warn(
        "WARNING: Scopes #{scopes_with_claim.map(&:name).to_sentence} " \
        "have the #{key} claim declared. OIDCProvider will use the first " \
        "one to populate the #{type} response."
      )
    end
  end
end
