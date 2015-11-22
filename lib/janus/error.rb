module Janus

  class Error < StandardError

    def initialize(error_code, error_info)
      @code, @info = error_code, error_info
    end

    def message
      "<Code: #{@code}> <Info: #{@info}>"
    end

    def code
      @code
    end

  end
end
