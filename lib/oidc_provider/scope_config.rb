# frozen_string_literal: true

module OIDCProvider
  class ScopeConfig
    attr_accessor :force_claim, :requested_claims, :scope

    def initialize(scope, requested_claims)
      @force_claim = {}
      @requested_claims = requested_claims
      @scope = scope
    end

    def add_force_claim(key_value)
      raise ArgumentError unless key_value.is_a?(Hash)

      # Only stores keys where the value is not `nil` thanks to the `.compact`
      # method.
      @force_claim.merge!(key_value.compact)
    end

    def name
      @scope.name
    end
  end
end
