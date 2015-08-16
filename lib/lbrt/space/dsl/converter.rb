class Lbrt::Space::DSL::Converter
  def self.convert(exported, options = {})
    self.new(exported, options).convert
  end

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
    output_spaces(@exported)
  end

  private


  def output_spaces(space_by_name_or_id)
    spaces = []

    space_by_name_or_id.sort_by {|k, v| k.to_s }.map do |name_or_id, attrs|
      next unless target_matched?(name_or_id)
      spaces << output_space(name_or_id, attrs)
    end

    spaces.join("\n")
  end

  def output_space(name_or_id, attrs)
    chart_by_name_or_id = attrs.fetch('charts')

    <<-EOS
space #{name_or_id.inspect} do
  #{output_charts(chart_by_name_or_id)}
end
    EOS
  end

  def output_charts(chart_by_name_or_id)
    if chart_by_name_or_id.empty?
      '# no chart'
    else
      # Don't sort!
      chart_by_name_or_id.map {|name_or_id, attrs|
        output_chart(name_or_id, attrs)
      }.join("\n").strip
    end
  end

  def output_chart(name_or_id, attrs)
    type = attrs.fetch('type')
    streams = attrs.fetch('streams')

    <<-EOS
  chart #{name_or_id.inspect} do
    type #{type.inspect}
    #{output_streams(streams)}
  end
    EOS
  end

  def output_streams(streams)
    if streams.empty?
      '# no stream'
    else
      streams.map {|i| output_stream(i) }.join.strip
    end
  end

  def output_stream(stream)
    metric = stream.fetch('metric')
    type = stream.fetch('type')
    source = stream.fetch('source')
    group_function = stream.fetch('group_function')
    summary_function = stream.fetch('summary_function')

    <<-EOS
    stream do
      metric #{metric.inspect}
      type #{type.inspect}
      source #{source.inspect}
      group_function #{group_function.inspect}
      summary_function #{summary_function.inspect}
    end
    EOS
  end

  def target_matched?(str)
    if @options[:target]
      str =~ @options[:target]
    else
      true
    end
  end
end
