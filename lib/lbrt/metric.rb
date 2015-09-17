class Lbrt::Metric
  include Lbrt::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def list
    json = {}
    metric_names = build_metric_names

    metric_names.each do |name|
      json[name] = {
        url: metric_url(name),
      }
    end

    puts JSON.pretty_generate(json)
  end

  def peco
    metric_names = build_metric_names
    result = PecoSelector.select_from(metric_names)

    result.each do |name|
      url = metric_url(name)
      Lbrt::Utils.open(url)
    end
  end

  private

  def build_metric_names
    metric_names = @client.metrics.get.map {|mtrc|
      mtrc.fetch('name')
    }.select {|name|
      Lbrt::Utils.matched?(name, @options[:target])
    }

    metric_names
  end

  def metric_url(name)
    "https://metrics.librato.com/s/metrics/#{name}"
  end
end
