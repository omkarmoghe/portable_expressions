# frozen_string_literal: true

module PortableExpressions
  # Adds JSON serialization capabilities to each object.
  module Serializable
    def as_json
      {
        object: self.class.name
      }
    end

    def to_json(pretty: false)
      pretty ? JSON.pretty_generate(as_json) : JSON.generate(as_json)
    end
  end
end
