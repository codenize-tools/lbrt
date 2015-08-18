class Lbrt::Space::DSL::Context
  include Lbrt::Utils::ContextHelper

  def self.eval(dsl, path, options = {})
    self.new(path, options) {
      eval(dsl, binding, path)
    }
  end

  attr_reader :result

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @templates = {}
    @result = {}
    instance_eval(&block)
  end

  private

  def template(name, &block)
    @templates[name] = block
  end

  def space(name_or_id, &block)
    if @result[name_or_id]
      raise "Space `#{name_or_id}` is already defined"
    end

    spc = Lbrt::Space::DSL::Context::Space.new(name_or_id, @templates, &block).result
    @result[name_or_id] = spc
  end
end
