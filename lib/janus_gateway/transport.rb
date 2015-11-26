module JanusGateway

  class Transport

    include Events::Emitter

    def initialize
      @extra_data = {}
    end

    def run
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

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

    # @param [Hash] data
    def register_extra_data(data)
      @extra_data.merge!(data)
    end

    def clear_extra_data
      @extra_data = {}
    end

    # @return [Hash]
    def extra_data
      @extra_data
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
