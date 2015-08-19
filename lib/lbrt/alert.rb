class Lbrt::Alert
  include Lbrt::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
    @driver = Lbrt::Driver.new(@client, @options)
  end

  def peco
    alert_by_name = {}

    @client.alerts.get.each do |alrt|
      alert_id = alrt.fetch('id')
      name = alrt.fetch('name')
      next unless Lbrt::Utils.matched?(name, @options[:target])
      alert_by_name[name] = alert_id
    end

    result = PecoSelector.select_from(alert_by_name)

    result.each do |alert_id|
      url = "https://metrics.librato.com/alerts#/#{alert_id}"
      Lbrt::Utils.open(url)
    end
  end

  def export(export_options = {})
    exported = Lbrt::Alert::Exporter.export(@client, @options)
    Lbrt::Alert::DSL.convert(exported, @options)
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    expected = load_file(file)
    actual = Lbrt::Alert::Exporter.export(@client, @options)
    walk_alerts(expected, actual)
  end

  def walk_alerts(expected, actual)
    updated = false

    expected.each do |name, expected_alert|
      next unless Lbrt::Utils.matched?(name, @options[:target])
      actual_alert = actual.delete(name)

      if actual_alert
        updated = walk_alert(name, expected_alert, actual_alert) || updated
      else
        updated = @driver.create_alert(name, expected_alert) || updated
      end
    end

    actual.each do |name, actual_alert|
      next unless Lbrt::Utils.matched?(name, @options[:target])
      updated = @driver.delete_alert(name, actual_alert) || updated
    end

    updated
  end

  def walk_alert(name, expected, actual)
    updated = false

    actual_without_id = actual.dup
    alert_id = actual_without_id.delete('id')

    if differ?(expected, actual_without_id)
      updated = @driver.update_alert(name, expected.merge('id' => alert_id), actual) || updated
    end

    updated
  end

  def differ?(alert1, alert2)
    alert1 = normalize(alert1)
    alert2 = normalize(alert2)
    alert1 != alert2
  end

  def normalize(alert)
    alert = alert.dup

    alert['conditions'] = alert.fetch('conditions').map {|i|
      i.delete('id')
      i
    }.sort_by(&:to_s)

    alert['services'] = alert.fetch('services').map {|i| i.fetch('id') }.sort
    alert
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Lbrt::Alert::DSL.parse(@client, f.read, file)
      end
    elsif [File, Tempfile].any? {|i| file.kind_of?(i) }
      Lbrt::Alert::DSL.parse(@client, file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
