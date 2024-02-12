# frozen_string_literal: true

module OIDCProvider
  class UserInfosController < ApplicationController
    before_action :require_access_token

    def show
      render json: user_info
    end

    private

    def user_info
      AccountToUserInfo.new(current_token.authorization.user_info_scopes)
                       .call(current_token.authorization.account)
    end
  end
end
