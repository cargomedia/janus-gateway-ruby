class WebSocketClientMock
  include Events::Emitter

  def initialize(response)
    @response = response
    connect_mock
  end

  def connect_mock
    Thread.new do
      sleep(0.1)
      emit :open
    end
  end

  def send(data)
    data_json = JSON.parse(data)

    janus_action_name = data_json['janus'].to_sym
    reply_message = @response[janus_action_name]

    Thread.new do
      sleep(0.1)
      emit :message, Faye::WebSocket::API::MessageEvent.new('message', data: reply_message)
    end
  end

  def receive_message(message)
    Thread.new do
      sleep(0.1)
      emit :message, Faye::WebSocket::API::MessageEvent.new('message', data: message)
    end
  end

  def close
    Thread.new do
      sleep(0.1)
      emit :close
    end
  end
end
