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
    service_by_title = {}

    services.each do |s|
      title = s.delete('title')

      if service_by_title[title]
        raise "Duplicate service title exists: #{title}"
      end

      EXCLUDE_KEYS.each do |key|
        s.delete(key)
      end

      service_by_title[title] = s
    end

    service_by_title
  end
end
