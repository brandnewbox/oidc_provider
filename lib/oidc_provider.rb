require "openid_connect"
require "oidc_provider/engine"

module OIDCProvider

  module Scopes
    OpenID = "openid"
    Profile = "profile"
    Email = "email"
    Address = "address"
  end

  autoload :TokenEndpoint, 'oidc_provider/token_endpoint'
  autoload :ClientStore, 'oidc_provider/client_store'
  autoload :Client, 'oidc_provider/client'
  autoload :AccountToUserInfo, 'oidc_provider/account_to_user_info'
  autoload :Scope, 'oidc_provider/scope'
  autoload :UserInfoBuilder, 'oidc_provider/user_info_builder'

  mattr_accessor :issuer

  mattr_accessor :supported_scopes
  @@supported_scopes = []

  mattr_accessor :clients
  @@clients = []

  mattr_accessor :account_class
  @@account_class = "User"

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
    yield self
  end
end
