module Errors
  class InvalidQuery < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end
  end
end
