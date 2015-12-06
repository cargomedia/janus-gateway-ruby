module JanusGateway
  class Transport
    include Events::Emitter

    def run
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def connect
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def disconnect
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @param [Hash] data
    def send(_data)
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @param [Hash] data
    # @return [Concurrent::Promise]
    def send_transaction(_data)
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [TrueClass, FalseClass]
    def connected?
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
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
