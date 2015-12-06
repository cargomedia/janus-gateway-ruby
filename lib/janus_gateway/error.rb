module JanusGateway
  class Error < StandardError
    # @return [Integer]
    attr_reader :code

    # @return [String]
    attr_reader :info

    # @param [Integer] error_code
    # @param [String] error_info
    def initialize(error_code, error_info)
      @code = error_code
      @info = error_info

      super("<Code: #{code}> <Info: #{info}>")
    end
  end
end
