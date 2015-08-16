class Lbrt::Driver
  include Lbrt::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  # Space

  def create_space(name, expected)
    updated = false

    log(:info, "Create Space `#{name}`", :color => :cyan)

    unless name.is_a?(String)
      raise TypeError, "wrong argument type #{name.class}: #{name.inspect} (expected String)"
    end

    unless @options[:dry_run]
      response = @client.spaces.post('name' => name)
      expected['id'] = response.fetch('id')
      updated = true
    end

    updated
  end

  def delete_space(name_or_id, actual)
    updated = false

    log(:info, "Delete Space `#{name_or_id}`", :color => :red)

    space_id = actual.fetch('id')

    unless @options[:dry_run]
      @client.spaces(space_id).delete
      updated = true
    end

    updated
  end

  # Chart

  def create_chart(space_name_or_id, space_id, name, expected)
    updated = false

    log(:info, "Create Space `#{space_name_or_id}` > Chart `#{name}`", :color => :cyan)

    unless name.is_a?(String)
      raise TypeError, "wrong argument type #{name.class}: #{name.inspect} (expected String)"
    end

    unless @options[:dry_run]
      response = @client.spaces(space_id).charts.post(expected.merge('name' => name))
      expected['id'] = response.fetch('id')
      updated = true
    end

    updated
  end

  def delete_chart(space_name_or_id, space_id, name_or_id, actual)
    updated = false

    log(:info, "Delete Space `#{space_name_or_id}` > `#{name_or_id}`", :color => :red)

    chart_id = actual.fetch('id')

    unless @options[:dry_run]
      @client.spaces(space_id).charts(chart_id).delete
      updated = true
    end

    updated
  end

  def update_chart(space_name_or_id, space_id, name_or_id, expected, actual)
    updated = false

    log(:info, "Update Space `#{space_name_or_id}` > Chart: #{name_or_id}", :color => :green)

    delta = diff(Lbrt::Space::DSL::Converter,
      {space_name_or_id => {'charts' => {name_or_id => actual}}},
      {space_name_or_id => {'charts' => {name_or_id => expected}}}
    )

    log(:info, delta)

    chart_id = actual.fetch('id')

    unless @options[:dry_run]
      params = chart_to_update_params(expected)
      @client.spaces(space_id).charts(chart_id).put(params)
      updated = true
    end

    updated
  end

  # Alert

  def create_alert(name, expected)
    updated = false

    log(:info, "Create Alert `#{name}`", :color => :cyan)

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

    log(:info, "Delete Alert `#{name}`", :color => :red)

    alert_id = actual.fetch('id')

    unless @options[:dry_run]
      @client.alerts(alert_id).delete
      updated = true
    end

    updated
  end

  def update_alert(name, expected, actual)
    updated = false

    log(:info, "Update Alert `#{name}`", :color => :green)
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

    log(:info, "Create Service `#{type}/#{title}`", :color => :cyan)

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

    log(:info, "Delete Service `#{type}/#{title}`", :color => :red)

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

    log(:info, "Update Service `#{type}/#{title}`", :color => :green)
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

  def chart_to_update_params(chat)
    params = chat.dup
    # XXX: Correct?
    params['chart_type'] = params.delete('type')
    params['max'] ||= nil
    params['min'] ||= nil
    params['label'] ||= nil
    params
  end
end
