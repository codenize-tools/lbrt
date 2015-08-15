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
    services = @client.services.get
    normalize(services)
  end

  def normalize(services)
    service_by_key = {}

    services.each do |srvs|
      type = srvs.delete('type')
      title = srvs.delete('title')
      service_key = [type, title]

      if service_by_key[service_key]
        raise "Duplicate service type/title exists: #{type}/#{title}"
      end

      service_by_key[service_key] = srvs
    end

    service_by_key
  end
end
