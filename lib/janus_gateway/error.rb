module JanusGateway

  class Error < StandardError

    def initialize(error_code, error_info)
      @code, @info = error_code, error_info
    end

    # @return [String]
    def message
      "<Code: #{@code}> <Info: #{@info}>"
    end

    # @return [Integer]
    def code
      @code.to_i
    end

  end
end
