class Lbrt::Space::Exporter
  DEFAULT_CONCURRENCY = 32

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
    spaces = @client.spaces.get
    normalize_spaces(spaces)
  end

  private

  def normalize_spaces(spaces)
    space_by_name_or_id = {}
    concurrency = @options[:export_concurrency] || DEFAULT_CONCURRENCY

    Parallel.each(spaces, :in_threads => concurrency) do |spc|
      space_id = spc.fetch('id')
      name_or_id = spc.fetch('name') || space_id
      next unless Lbrt::Utils.matched?(name_or_id, @options[:target])
      charts = @client.spaces(space_id).charts.get

      if space_by_name_or_id[name_or_id]
        raise "Duplicate space name exists: #{name}"
      end

      space_by_name_or_id[name_or_id] = {
        'id' => space_id,
        'charts' => normalize_charts(charts),
      }
    end

    space_by_name_or_id
  end

  def normalize_charts(charts)
    chart_by_name_or_id = {}

    charts.each do |chrt|
      name_or_id = chrt.delete('name')
      name_or_id = chrt['id'] if name_or_id.empty?
      chrt.delete('space_id')
      chart_by_name_or_id[name_or_id] = chrt
    end

    chart_by_name_or_id
  end
end
