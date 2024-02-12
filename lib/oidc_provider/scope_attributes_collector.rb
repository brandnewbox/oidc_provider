# frozen_string_literal: true

# The aim of this class is to collect the method names from a given scope block
# added to the configuration from `add_scope` method.
class ScopeAttributesCollector
  # This class is used in order to create a context which is always happy about
  # the requested method so that this `ScopeAttributesCollector` never reach an
  # `undefined method` error and such and collect happilly all the block
  # method names.
  class HappyWorld
    # When using something like [user.first_name, user.last_name].join(' ') in a
    # scope, the `to_str` method is called and must return a string.
    # Since we are in an Happy World, let's say it!
    def to_str
      'HappyWorld'
    end

    def method_missing(*_) # rubocop:disable Style/MissingRespondToMissing
      HappyWorld.new
    end
  end

  attr_reader :collecteds

  def initialize
    @source = HappyWorld.new
    @collecteds = []
  end

  def run(&block)
    # Redirects all method calls to this class so that all the method_missing
    # are forwarded bellow in this class.
    instance_exec(@source, &block)
  end

  def method_missing(sym, *_) # rubocop:disable Style/MissingRespondToMissing
    @collecteds |= [sym]
  end
end
