OIDCProvider::Engine.routes.draw do
  match 'authorizations' => 'authorizations#create', via: [:get, :post]
  resource :user_info, only: :show
  get 'sessions/logout', to: 'sessions#destroy', as: :end_session

  post 'tokens', to: proc { |env| OIDCProvider::TokenEndpoint.new.call(env) }
  get 'jwks.json', as: :jwks, to: proc { |env| [200, {'Content-Type' => 'application/json'}, [OIDCProvider::IdToken.config[:jwk_set].to_json]] }
end
