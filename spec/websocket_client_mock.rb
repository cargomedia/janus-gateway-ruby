class WebSocketClientMock

  include EventEmitter

  def initialize(response)
    @response = response
    connect_mock
  end

  def connect_mock
    Thread.new do
      sleep(0.1)
      self.emit :open, EventMock.new
    end
  end

  def send(data)
    data_json = JSON.parse(data)

    janus_action_name = data_json['janus'].to_sym
    reply_message = @response[janus_action_name]

    Thread.new do
      sleep(0.1)
      self.emit :message, EventMock.new(reply_message)
    end
  end

  def close
    Thread.new do
      sleep(0.1)
      self.emit :close, EventMock.new
    end
  end
end
