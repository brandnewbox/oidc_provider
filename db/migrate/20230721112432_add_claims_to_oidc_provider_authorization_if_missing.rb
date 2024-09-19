# frozen_string_literal: true

class AddClaimsToOIDCProviderAuthorizationIfMissing < ActiveRecord::Migration[5.1]
  def up
    return if ActiveRecord::Base.connection.column_exists?(:oidc_provider_authorizations, :claims)

    add_column :oidc_provider_authorizations, :claims, :text
  end

  def down
    remove_column :oidc_provider_authorizations, :claims
  end
end
