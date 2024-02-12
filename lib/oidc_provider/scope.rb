# frozen_string_literal: true

module OIDCProvider
  class Scope
    attr_accessor :claims, :name, :work

    def initialize(name, &block)
      @name = name
      @work = block

      @claims = OIDCProvider.claims_from_scope(self)
      inject_claims_to_id_token_if_needed!
    end

    private

    # Since the openid_connect gem is limiting the allowed attributes on the
    # response classes, this gem declares more optional attributes on the
    # OpenIDConnect::ResponseObject::IdToken class.
    #
    # NOTE : This is done when adding a scope to this gem, so only once at the
    #        app's boot time when initializing this gem.
    # NOTE : Ideally the openid_connect gem should be patched in order to allow
    #        more claims without this hack.
    def inject_claims_to_id_token_if_needed!
      missings = @claims - OpenIDConnect::ResponseObject::IdToken.all_attributes

      return if missings.empty?

      OpenIDConnect::ResponseObject::IdToken.attr_optional(*missings)
    end
  end
end
