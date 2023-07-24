# frozen_string_literal: true

module OIDCProvider
  class AccountToUserInfo
    def initialize(scope_names)
      @scope_names = scope_names
    end

    def call(account)
      OpenIDConnect::ResponseObject::UserInfo.new(
        sub: account.send(OIDCProvider.account_identifier)
      ).tap do |user_info|
        scopes.each do |scope|
          ResponseObjectBuilder.new(user_info, account).run(&scope.work)
        end
      end
    end

    private

    def scopes
      @scope_names.map { |name| OIDCProvider.find_scope(name) }.compact
    end
  end
end
