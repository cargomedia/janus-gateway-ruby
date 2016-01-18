class HttpDummyJanusServer
  def initialize(response)
    @response = response
  end

  def respond(data)
    data_json = JSON.parse(data)
    janus_action_name = data_json['janus'].to_sym

    sleep(0.1)
    @response[janus_action_name]
  end
end
