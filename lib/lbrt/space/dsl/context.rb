class Lbrt::Space::DSL::Context
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

  def space(name_or_id, &block)
    if @result[name_or_id]
      raise "Space `#{name_or_id}` is already defined"
    end

    spc = Lbrt::Space::DSL::Context::Space.new(@context, name_or_id, &block).result
    @result[name_or_id] = spc
  end
end
