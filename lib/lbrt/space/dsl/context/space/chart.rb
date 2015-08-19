class Lbrt::Space::DSL::Context::Space::Chart
  include Lbrt::Utils::TemplateHelper

  REQUIRED_ATTRIBUTES = %w(
    type
  )

  def initialize(context, space_name_or_id, name_or_id, &block)
    @context = context.merge(:chart_name => name_or_id)
    @space_name_or_id = space_name_or_id
    @name_or_id = name_or_id
    @result = {'streams' => []}
    instance_eval(&block)
  end

  attr_reader :context

  def result
    REQUIRED_ATTRIBUTES.each do |name|
      unless @result.has_key?(name)
        raise "Space `#{@space_name_or_id}` > Chart `#{@name_or_id}` > `#{name}` is not defined"
      end
    end

    @result
  end

  private

  def type(value)
    @result['type'] = value.to_s
  end

  def stream(&block)
    @result['streams'] << Lbrt::Space::DSL::Context::Space::Chart::Stream.new(@context, @space_name_or_id, @name_or_id, &block).result
  end

  def max(value)
    @result['max'] = value.to_f
  end

  def min(value)
    @result['min'] = value.to_f
  end

  def label(value)
    @result['label'] = value.to_s
  end
end
