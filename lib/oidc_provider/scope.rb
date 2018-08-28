module OIDCProvider
  class Scope
    attr_accessor :name, :work

    def initialize(name, &block)
      @name = name
      @work = block
    end
  end
end