class HttpDummyJanusServer
  def initialize(response)
    @response = response
  end

  # @param [Hash] data
  def respond(data)
    janus_action_name = data[:janus].to_sym
    response = JSON.parse(@response[janus_action_name])
    Concurrent::Promise.fulfill(response)
  end
end
