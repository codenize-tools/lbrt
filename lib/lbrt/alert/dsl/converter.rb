class Lbrt::Alert::DSL::Converter
  def self.convert(exported, options = {})
    self.new(exported, options).convert
  end

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
    output_alerts(@exported)
  end

  private

  def output_alerts(alert_by_name)
    alerts = []

    alert_by_name.sort_by(&:first).map do |name, attrs|
      next unless target_matched?(name)
      alerts << output_alert(name, attrs)
    end

    alerts.join("\n")
  end

  def output_alert(name, attrs)
    description = attrs.fetch('description')
    attributes = attrs.fetch('attributes')
    active = attrs.fetch('active')
    rearm_seconds = attrs.fetch('rearm_seconds')
    rearm_per_signal = attrs.fetch('rearm_per_signal')

    conditions = attrs.fetch('conditions')
    services = attrs.fetch('services')

    if attributes.empty?
      attributes = "\n" + <<-EOS.chomp
  #attributes "runbook_url"=>"http://example.com"
      EOS
    else
      attributes = "\n" + <<-EOS.chomp
  attributes #{Lbrt::Utils.unbrace(attributes.inspect)}
      EOS
    end

    <<-EOS
alert #{name.inspect} do
  description #{description.inspect}#{
  attributes}
  active #{active.inspect}
  rearm_seconds #{rearm_seconds.inspect}
  rearm_per_signal #{rearm_per_signal.inspect}

  #{output_conditions(conditions)}

  #{output_services(services)}
end
    EOS
  end

  def output_conditions(conditions)
    if conditions.empty?
      '# no condition'
    else
      conditions.map {|i| output_condition(i) }.join("\n").strip
    end
  end

  def output_condition(condition)
    type = condition.fetch('type')
    metric_name = condition.fetch('metric_name')
    source = condition.fetch('source')

    threshold = condition['threshold']
    summary_function = condition['summary_function']
    duration = condition['duration']

    out = <<-EOS
  condition do
    type #{type.inspect}
    metric_name #{metric_name.inspect}
    source #{source.inspect}
    EOS

    out << <<-EOS if threshold
    threshold #{threshold.inspect}
    EOS

    out << <<-EOS if summary_function
    summary_function #{summary_function.inspect}
    EOS

    out << <<-EOS if duration
    duration #{duration.inspect}
    EOS

    out << <<-EOS
  end
    EOS
  end

  def target_matched?(str)
    if @options[:target]
      stri =~ @options[:target]
    else
      true
    end
  end

  def output_services(services)
    if services.empty?
      '# no service'
    else
      services.map {|i| output_service(i) }.join.strip
    end
  end

  def output_service(service)
    type = service.fetch('type')
    title = service.fetch('title')

    <<-EOS
  service #{type.inspect}, #{title.inspect}
    EOS
  end
end
