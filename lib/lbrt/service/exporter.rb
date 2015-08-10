class Lbrt::Service::Exporter
  class << self
    def export(client, options = {})
      self.new(client, options).export
    end
  end # of class methods

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def export
    # XXX:
  end
end
