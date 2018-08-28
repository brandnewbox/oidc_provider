class CreateOIDCProviderAccessTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :oidc_provider_access_tokens do |t|
      t.references :authorization, foreign_key: {to_table: :oidc_provider_authorizations}, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :oidc_provider_access_tokens, :token, unique: true
  end
end
