module Expressive
  class Scalar
    include Serializable

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      value.to_s
    end

    def as_json
      super.merge(
        value: value
      )
    end
  end
end
