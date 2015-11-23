module JanusGateway

  class Transport

    include EventEmitter

    def initialize(url, protocol = 'janus-protocol')
      @url = url
      @protocol = protocol
    end

    def connect
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def disconnect
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def send(data)
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def send_transaction(data)
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def close
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def ready_state
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def has_client?
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def has_connection?
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

  end
end
