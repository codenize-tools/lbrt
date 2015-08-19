class Lbrt::Alert::DSL::Context::Alert::Condition
  include Lbrt::Utils::TemplateHelper

  REQUIRED_ATTRIBUTES = %w(
    type
    metric_name
    source
  )

  REQUIRED_ATTRIBUTES_BY_TYPE = {
    'above' => %W(threshold summary_function),
    'below' => %W(threshold summary_function),
    'active' => %W(duration),
  }

  def initialize(context, alert_name, &block)
    @context = context.dup
    @alert_name = alert_name
    @result = {}
    instance_eval(&block)
  end

  attr_reader :context

  def result
    REQUIRED_ATTRIBUTES.each do |name|
      unless @result.has_key?(name)
        raise "Alert `#{@alert_name}` > Condition > `#{name}` is not defined"
      end
    end

    REQUIRED_ATTRIBUTES_BY_TYPE.fetch(@result['type'], {}).each do |name|
      unless @result.has_key?(name)
        raise "Alert `#{@alert_name}` > Condition > `#{name}` is not defined"
      end
    end

    @result
  end

  private

  def type(value)
    @result['type'] = value.to_s
  end

  def metric_name(value)
    @result['metric_name'] = value.to_s
  end

  def source(value)
    @result['source'] = value.nil? ? nil : value.to_s
  end

  def threshold(value)
    @result['threshold'] = value.to_f
  end

  def summary_function(value)
    @result['summary_function'] = value.to_s
  end

  def duration(value)
    @result['duration'] = value.to_i
  end
end
