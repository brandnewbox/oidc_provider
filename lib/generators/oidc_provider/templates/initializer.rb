OIDCProvider.configure do |config|
  config.issuer = "https://myoidcprovider.org"
  # config.account_class = "Administrator"

  config.add_client do
    name "Test Client"
    identifier '0001'
    secret '27ffb...'
    redirect_uri 'https://demo.c2id.com/oidc-client/cb'
  end

  config.add_client do
    name "Client 1"
    identifier "client_01"
    secret "6f14c..."
    redirect_uri "https://clientone.com/TDE/openid_connect_login"
  end

  config.add_scope OIDCProvider::Scopes::Profile do |user|
    name user.full_name
    given_name user.first_name
    family_name user.last_name
  end

  config.add_scope OIDCProvider::Scopes::Email do |user|
    email user.email
    email_verified false
  end

end