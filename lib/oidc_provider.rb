# frozen_string_literal: true

require 'openid_connect'
require 'oidc_provider/engine'
require 'oidc_provider/errors'

module OIDCProvider
  # rubocop:disable Naming/ConstantName
  module Scopes
    OpenID = 'openid'
    Profile = 'profile'
    Email = 'email'
    Address = 'address'
  end
  # rubocop:enable Naming/ConstantName

  autoload :AccountToUserInfo, 'oidc_provider/account_to_user_info'
  autoload :Client, 'oidc_provider/client'
  autoload :ClientStore, 'oidc_provider/client_store'
  autoload :IdTokenBuilder, 'oidc_provider/id_token_builder'
  autoload :ResponseObjectBuilder, 'oidc_provider/response_object_builder'
  autoload :Scope, 'oidc_provider/scope'
  autoload :ScopeAttributesCollector, 'oidc_provider/scope_attributes_collector'
  autoload :ScopeConfig, 'oidc_provider/scope_config'
  autoload :TokenEndpoint, 'oidc_provider/token_endpoint'

  mattr_accessor :issuer

  mattr_accessor :supported_scopes
  @@supported_scopes = []

  mattr_accessor :clients
  @@clients = []

  mattr_accessor :account_class
  @@account_class = 'User'

  mattr_accessor :current_account_method
  @@current_account_method = :current_user

  mattr_accessor :current_authentication_method
  @@current_authentication_method = :authenticate_user!

  mattr_accessor :current_unauthenticate_method
  @@current_unauthenticate_method = :sign_out

  mattr_accessor :account_identifier
  @@account_identifier = :id

  mattr_accessor :after_sign_out_path

  def self.add_client(&block)
    @@clients << Client::Builder.new(&block).build
  end

  def self.add_scope(name, &block)
    @@supported_scopes << Scope.new(name, &block)
  end

  def self.configure
    @@clients = []

    @@supported_scopes = [open_id_scope]

    yield self
  end

  def self.find_all_scopes_with_claim(name)
    @@supported_scopes.select { |scope| scope.claims.include?(name.to_sym) }
  end

  def self.find_scope(name)
    @@supported_scopes.detect { |scope| scope.name == name }
  end

  # Returns the claims from a given scope
  def self.claims_from_scope(scope)
    collector = ScopeAttributesCollector.new
    collector.run(&scope.work)
    collector.collecteds
  end

  def self.open_id_scope # rubocop:disable Metrics/AbcSize
    Scope.new(OIDCProvider::Scopes::OpenID) do |id_token|
      iss OIDCProvider.issuer
      sub id_token.account.send(OIDCProvider.account_identifier)
      aud id_token.authorization.client_id
      nonce id_token.nonce
      exp id_token.expires_at.to_i
      iat id_token.created_at.to_i
    end
  end

  # Returns all the claims from all the `@@supported_scopes`
  def self.supported_claims
    @@supported_scopes.flat_map(&:claims)
  end
end
