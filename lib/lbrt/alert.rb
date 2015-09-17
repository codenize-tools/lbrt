class Lbrt::Alert
  include Lbrt::Logger::Helper

  DEFAULT_CONCURRENCY = 32

  def initialize(client, options = {})
    @client = client
    @options = options
    @driver = Lbrt::Driver.new(@client, @options)
  end

  def list
    json = {}
    alert_by_name = build_alert_by_name

    alert_by_name.select {|name, alrt|
      @options[:status].nil? or @options[:status] == alrt[:status]
    }.each {|name, alrt|
      alert_id = alrt[:id]

      json[alert_id] = {
        name: name,
        url: alert_url(alert_id),
        status: alrt[:status],
      }
    }

    puts JSON.pretty_generate(json)
  end

  def peco
    alert_id_by_name = {}

    build_alert_by_name.select {|name, alrt|
      @options[:status].nil? or @options[:status] == alrt[:status]
    }.map {|name, alrt| alert_id_by_name[name] = alrt[:id] }

    unless alert_id_by_name.empty?
      result = PecoSelector.select_from(alert_id_by_name)

      result.each do |alert_id|
        url = alert_url(alert_id)
        Lbrt::Utils.open(url)
      end
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

  def build_alert_by_name
    alert_by_name = {}

    @client.alerts.get.each do |alrt|
      alert_id = alrt.fetch('id')
      name = alrt.fetch('name')
      next unless Lbrt::Utils.matched?(name, @options[:target])
      alert_by_name[name] = {id: alert_id}
    end

    concurrency = @options[:concurrency] || DEFAULT_CONCURRENCY

    Parallel.each(alert_by_name, :in_threads => concurrency) do |name, alrt|
      alert_id = alrt[:id]
      status = @client.alerts(alert_id).status.get
      alrt[:status] = status['status']
    end

    alert_by_name
  end

  def alert_url(alert_id)
    "https://metrics.librato.com/alerts#/#{alert_id}"
  end

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
