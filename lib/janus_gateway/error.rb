module JanusGateway

  class Error < StandardError

    # @param [Integer] error_code
    # @param [String] error_info
    def initialize(error_code, error_info)
      @code, @info = error_code, error_info
    end

    # @return [String]
    def message
      "<Code: #{code}> <Info: #{info}>"
    end

    # @return [Integer]
    def code
      @code
    end

    # @return [String]
    def info
      @info
    end

  end
end
