class Lbrt::Service::DSL::Context
  include Lbrt::Utils::ContextHelper
  include Lbrt::Utils::TemplateHelper

  def self.eval(dsl, path, options = {})
    self.new(path, options) {
      eval(dsl, binding, path)
    }
  end

  attr_reader :result
  attr_reader :context

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @result = {}

    @context = Hashie::Mash.new(
      :path => path,
      :options => options,
      :templates => {}
    )

    instance_eval(&block)
  end

  private

  def service(type, title, &block)
    type = type.to_s
    title = title.to_s
    key = [type, title]

    if @result[key]
      raise "Service `#{type}/#{title}` is already defined"
    end

    srvc = Lbrt::Service::DSL::Context::Service.new(@context, type, title, &block).result
    @result[key] = srvc
  end
end
