module Janus

  class Resource

    include EventEmitter

    attr_accessor :id

    def initialize(id = nil)
      @id = id
    end

    def name
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def create
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def destroy
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def on_created
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end
  end
end
