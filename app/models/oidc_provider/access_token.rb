module OIDCProvider
  class AccessToken < ApplicationRecord
    belongs_to :authorization

    scope :valid, -> { where(arel_table[:expires_at].gteq(Time.now.utc)) }

    attribute :token, :string, default: -> { SecureRandom.hex 32 }
    attribute :expires_at, :datetime, default: -> { 1.hours.from_now } 

    def to_bearer_token
      Rack::OAuth2::AccessToken::Bearer.new(
        access_token: token,
        expires_in: (expires_at - Time.now).to_i
      )
    end
  end
end
