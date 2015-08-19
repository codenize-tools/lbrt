class Lbrt::Metric
  include Lbrt::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def peco
    metric_names = @client.metrics.get.map {|mtrc|
      mtrc.fetch('name')
    }.select {|name|
      Lbrt::Utils.matched?(name, @options[:target])
    }

    result = PecoSelector.select_from(metric_names)

    result.each do |name|
      url = "https://metrics.librato.com/s/metrics/#{name}"
      Lbrt::Utils.open(url)
    end
  end
end
