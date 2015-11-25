module JanusGateway

  class Transport

    include Events::Emitter

    def connect
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def disconnect
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @param [Hash] data
    def send(data)
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @param [Hash] data
    # @return [Concurrent::Promise]
    def send_transaction(data)
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [TrueClass, FalseClass]
    def is_connected?
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [String]
    def transaction_id_new
      transaction_id = ''
      24.times do
        transaction_id << (65 + rand(25)).chr
      end
      transaction_id
    end

  end
end
