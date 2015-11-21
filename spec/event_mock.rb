class EventMock

  def initialize(data = nil)
    @data = data || '{}'
  end

  def data
    @data
  end

end
