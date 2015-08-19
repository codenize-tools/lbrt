class Lbrt::Space
  include Lbrt::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
    @driver = Lbrt::Driver.new(@client, @options)
  end

  def peco
    space_by_name_or_id = {}

    @client.spaces.get.each do |spc|
      space_id = spc.fetch('id')
      name_or_id = spc.fetch('name') || space_id
      next unless Lbrt::Utils.matched?(name_or_id, @options[:target])
      space_by_name_or_id[name_or_id] = space_id
    end

    result = PecoSelector.select_from(space_by_name_or_id)

    result.each do |space_id|
      url = "https://metrics.librato.com/s/spaces/#{space_id}"
      Lbrt::Utils.open(url)
    end
  end

  def export(export_options = {})
    exported = Lbrt::Space::Exporter.export(@client, @options)
    Lbrt::Space::DSL.convert(exported, @options)
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    expected = load_file(file)
    actual = Lbrt::Space::Exporter.export(@client, @options)
    walk_spaces(expected, actual)
  end

  def walk_spaces(expected, actual)
    updated = false

    expected.each do |name_or_id, expected_space|
      next unless Lbrt::Utils.matched?(name_or_id, @options[:target])
      actual_space = actual.delete(name_or_id)

      if not actual_space and name_or_id.is_a?(Integer)
        actual_space = actual.values.find {|i| i['id'] == name_or_id }
      end

      unless actual_space
        updated = @driver.create_space(name_or_id, expected_space) || updated
        actual_space = expected_space.merge('charts' => {})

        # Set dummy id for dry-run
        actual_space['id'] ||= -1
      end

      updated = walk_space(name_or_id, expected_space, actual_space) || updated
    end

    actual.each do |name_or_id, actual_space|
      updated = @driver.delete_space(name_or_id, actual_space) || updated
    end

    updated
  end

  def walk_space(name_or_id, expected, actual)
    updated = false
    space_id = actual.fetch('id')
    expected_charts = expected.fetch('charts')
    actual_charts = actual.fetch('charts')
    updated = walk_charts(name_or_id, space_id, expected_charts, actual_charts) || updated
    updated
  end

  def walk_charts(space_name_or_id, space_id, expected, actual)
    updated = false

    expected.each do |name_or_id, expected_chart|
      actual_chart = actual.delete(name_or_id)

      if not actual_chart and name_or_id.is_a?(Integer)
        actual_chart = actual.values.find {|i| i['id'] == name_or_id }
      end

      if actual_chart
        updated = walk_chart(space_name_or_id, space_id, name_or_id, expected_chart, actual_chart) || updated
      else
        updated = @driver.create_chart(space_name_or_id, space_id, name_or_id, expected_chart) || updated
      end
    end

    actual.each do |name_or_id, actual_chart|
      updated = @driver.delete_chart(space_name_or_id, space_id, name_or_id, actual_chart) || updated
    end

    updated
  end

  def walk_chart(space_name_or_id, space_id, name_or_id, expected, actual)
    updated = false

    actual_without_id = actual.dup
    alert_id = actual_without_id.delete('id')

    if differ_chart?(expected, actual_without_id)
      updated = @driver.update_chart(space_name_or_id, space_id, name_or_id, expected.merge('id' => alert_id), actual) || updated
    end

    updated
  end

  def differ_chart?(chart1, chart2)
    chart1 = normalize_chart(chart1)
    chart2 = normalize_chart(chart2)
    chart1 != chart2
  end

  def normalize_chart(chart)
    chart = chart.dup
    chart_streams = chart['streams'].dup
    chart_streams.each {|i| i.delete('id') }
    chart['streams'] = chart_streams
    chart
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Lbrt::Space::DSL.parse(f.read, file)
      end
    elsif [File, Tempfile].any? {|i| file.kind_of?(i) }
      Lbrt::Space::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
