class HttpDummyJanusServer
  def initialize(response)
    @response = response
  end

  def respond(data)
    janus_action_name = data[:janus].to_sym

    sleep(0.1)
    JSON.parse(@response[janus_action_name])
  end
end
