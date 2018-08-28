class CreateOIDCProviderIdTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :oidc_provider_id_tokens do |t|
      t.references :authorization, foreign_key: {to_table: :oidc_provider_authorizations}
      t.string :nonce, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
