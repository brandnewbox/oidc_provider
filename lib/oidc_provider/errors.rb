# frozen_string_literal: true

module OIDCProvider
  module Errors
    # Allows one to catch all OIDCProvider errors
    class OIDCProviderError < StandardError; end

    # Raised when passed claims is not a Hash of hashes only.
    class InvalidClaimsFormatError < OIDCProviderError; end
  end
end
