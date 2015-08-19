class Lbrt::Space::DSL::Context::Space::Chart::Stream
  include Lbrt::Utils::TemplateHelper

  REQUIRED_ATTRIBUTES = %w(
    metric
    type
    source
    group_function
    summary_function
  )

  def initialize(context, space_name_or_id, chart_name_or_id, &block)
    @context = context.dup
    @space_name_or_id = space_name_or_id
    @chart_name_or_id = chart_name_or_id
    @result = {}
    instance_eval(&block)
  end

  attr_reader :context

  def result
    REQUIRED_ATTRIBUTES.each do |name|
      unless @result.has_key?(name)
        raise "Space `#{@space_name_or_id}` > Chart `#{@chart_name_or_id}` > Stream > `#{name}` is not defined"
      end
    end

    @result
  end

  private

  def metric(value)
    @result['metric'] = value.to_s
  end

  def type(value)
    @result['type'] = value.to_s
  end

  def source(value)
    @result['source'] = value.to_s
  end

  def group_function(value)
    @result['group_function'] = value.to_s
  end

  def summary_function(value)
    @result['summary_function'] = value.to_s
  end
end
