class Lbrt::Alert::DSL::Context
  include Lbrt::Utils::ContextHelper
  include Lbrt::Utils::TemplateHelper

  def self.eval(client, dsl, path, options = {})
    self.new(client, path, options) {
      eval(dsl, binding, path)
    }
  end

  attr_reader :result
  attr_reader :context

  def initialize(client, path, options = {}, &block)
    @path = path
    @options = options
    @result = {}
    @services = Lbrt::Service::Exporter.export(client, options)

    @context = Hashie::Mash.new(
      :path => path,
      :options => options,
      :templates => {}
    )

    instance_eval(&block)
  end

  private

  def alert(name, &block)
    name = name.to_s

    if @result[name]
      raise "Alert `#{name}` is already defined"
    end

    alrt = Lbrt::Alert::DSL::Context::Alert.new(@context, name, @services, &block).result
    @result[name] = alrt
  end
end
