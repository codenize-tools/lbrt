class Lbrt::Driver
  include Lbrt::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  # Alert

  def create_alert(name, expected)
    updated = false

    log(:info, "Create Alert: #{name}", :color => :cyan)

    unless @options[:dry_run]
      params = alert_to_params(name, expected)
      response = @client.alerts.post(params)
      expected['id'] = response.fetch('id')
      updated = true
    end

    updated
  end

  def delete_alert(name, actual)
    updated = false

    log(:info, "Delete Alert: #{name}", :color => :red)

    alert_id = actual.fetch('id')

    unless @options[:dry_run]
      @client.alerts(alert_id).delete
      updated = true
    end

    updated
  end

  def update_alert(name, expected, actual)
    updated = false

    log(:info, "Update Alert: #{name}", :color => :red)
    log(:info, diff(Lbrt::Alert::DSL::Converter, {name => actual}, {name => expected}))

    alert_id = actual.fetch('id')

    unless @options[:dry_run]
      params = alert_to_params(name, expected)
      @client.alerts(alert_id).put(params)
      updated = true
    end

    updated
  end

  # Service

  def create_service(key, expected)
    updated = false
    type, title = key

    log(:info, "Create Service: #{type}/#{title}", :color => :cyan)

    settings = expected.fetch('settings')

    unless @options[:dry_run]
      response = @client.services.post(
        'title'    => title,
        'type'     => type,
        'settings' => settings
      )

      expected['id'] = response.fetch('id')
      updated = true
    end

    updated
  end

  def delete_service(key, actual)
    updated = false
    type, title = key

    log(:info, "Delete Service: #{type}/#{title}", :color => :red)

    service_id = actual.fetch('id')

    unless @options[:dry_run]
      @client.services(service_id).delete
      updated = true
    end

    updated
  end

  def update_service(key, expected, actual)
    updated = false
    type, title = key

    log(:info, "Update Service: #{type}/#{title}", :color => :cyan)
    log(:info, diff(Lbrt::Service::DSL::Converter, {key => actual}, {key => expected}))

    service_id = actual.fetch('id')
    settings = expected.fetch('settings')

    unless @options[:dry_run]
      @client.services(service_id).put(
        'settings' => settings
      )

      updated = true
    end

    updated
  end

  private

  def diff(converter, obj1, obj2)
    diffy = Diffy::Diff.new(
      converter.convert(obj1),
      converter.convert(obj2),
      :diff => '-u'
    )

    diffy.to_s(@options[:color] ? :color : :text).gsub(/\s+\z/m, '')
  end

  def alert_to_params(name, alert)
    params = alert.dup
    params['name'] = name
    params['services'] = params.fetch('services').map {|i| i.fetch('id') }
    params
  end
end
