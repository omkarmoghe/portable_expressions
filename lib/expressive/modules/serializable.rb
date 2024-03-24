require "json"

module Expressive
  module Serializable
    def as_json
      {
        object: self.class.name
      }
    end

    def to_json(pretty: false)
      if pretty
        JSON.pretty_generate(as_json)
      else
        JSON.generate(as_json)
      end
    end
  end
end
