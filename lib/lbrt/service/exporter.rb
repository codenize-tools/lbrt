class Lbrt::Service::Exporter
  EXCLUDE_KEYS = %w(
    id
  )

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

    services.each do |s|
      type = s.delete('type')
      title = s.delete('title')

      service_key = [type, title]

      if service_by_key[service_key]
        raise "Duplicate service type/title exists: #{type}/#{title}"
      end

      EXCLUDE_KEYS.each do |key|
        s.delete(key)
      end

      service_by_key[service_key] = s
    end

    service_by_key
  end
end
