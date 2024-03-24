module Expressive
  class Variable
    include Serializable

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_s
      name
    end

    def as_json
      super.merge(
        name: name
      )
    end
  end
end
