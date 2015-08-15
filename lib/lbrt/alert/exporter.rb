class Lbrt::Alert::Exporter
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
    alerts = @client.alerts.get
    normalize(alerts)
  end

  def normalize(alerts)
    alert_by_name = {}

    alerts.each do |alrt|
      name = alrt.delete('name')

      if alert_by_name[name]
        raise "Duplicate alert name exists: #{name}"
      end

      %w(created_at updated_at version).each do |key|
        alrt.delete(key)
      end

      alert_by_name[name] = alrt
    end

    alert_by_name
  end
end
