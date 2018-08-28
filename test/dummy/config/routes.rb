Rails.application.routes.draw do
  mount Openid::Connect::Provider::Engine => "/openid-connect-provider"
end
