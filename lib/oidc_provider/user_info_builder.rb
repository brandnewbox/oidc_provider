module OIDCProvider
  class UserInfoBuilder
    attr_reader :user_info

    def initialize(user_info, account)
      @user_info = user_info
      @account = account
    end

    def run(&block)
      instance_exec(@account, &block)
    end

    def method_missing(sym, *args)
      @user_info.send("#{sym}=", *args)
    end
  end
end