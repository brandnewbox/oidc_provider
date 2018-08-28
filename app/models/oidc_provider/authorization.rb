module OIDCProvider
  class Authorization < ApplicationRecord
    belongs_to :account, class_name: OIDCProvider.account_class
    has_one :access_token
    has_one :id_token

    scope :valid, -> { where(arel_table[:expires_at].gteq(Time.now.utc)) }

    attribute :code, :string, default: -> { SecureRandom.hex 32 }
    attribute :expires_at, :datetime, default: -> { 5.minutes.from_now }

    serialize :scopes, JSON

    def expire!
      self.expires_at = Time.now
      self.save!
    end

    def access_token
      super || expire! && generate_access_token!
    end

    def id_token
      super || generate_id_token!
    end

    private

    def generate_access_token!
      token = create_access_token!
      token
    end

    def generate_id_token!
      token = build_id_token
      token.nonce = nonce
      token.save!
      token
    end
  end
end
