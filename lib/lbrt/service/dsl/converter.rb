class Lbrt::Service::DSL::Converter
  def self.convert(exported, options = {})
    self.new(exported, options).convert
  end

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
    output_services(@exported)
  end

  private

  def output_services(service_by_key)
    services = []

    service_by_key.sort_by(&:first).map do |key, attrs|
      next unless key.any? {|i| target_matched?(i) }
      services << output_service(key, attrs)
    end

    services.join("\n")
  end

  def output_service(key, attrs)
    type, title = key
    settings = attrs.fetch('settings')

    <<-EOS
service #{type.inspect}, #{title.inspect} do
  settings #{Lbrt::Utils.unbrace(settings.inspect)}
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
