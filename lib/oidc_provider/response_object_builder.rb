# frozen_string_literal: true

module OIDCProvider
  class ResponseObjectBuilder
    attr_reader :response_object

    def initialize(response_object, context, filter_claims = nil)
      @context = context
      @filter_claims = filter_claims
      @response_object = response_object
    end

    def run(&block)
      instance_exec(@context, &block)
    end

    def method_missing(sym, *args) # rubocop:disable Style/MissingRespondToMissing
      return if @filter_claims.present? && @filter_claims.include?(sym) == false

      @response_object.send("#{sym}=", *args)
    end
  end
end
