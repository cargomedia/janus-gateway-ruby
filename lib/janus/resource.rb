module Janus

  class Resource

    def name
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def on_created
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def destroy
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end
  end
end
