class Lbrt::Space::DSL::Context::Space
  def initialize(name_or_id, templates, &block)
    @name_or_id = name_or_id
    @templates = templates
    @result = {'charts' => {}}
    @context = Hashie::Mash.new(:space_name => name_or_id)
    instance_eval(&block)
  end

  attr_reader :result
  attr_reader :context

  private

  def include_template(template_name)
    tmplt = @templates[template_name]

    unless tmplt
      raise "Space `#{@name_or_id}`: Template `#{template_name}` is not defined"
    end

    instance_eval(&tmplt)
  end

  def chart(chart_name_or_id, &block)
    if @result[chart_name_or_id]
      raise "Space `#{@name_or_id}` > Chart `#{chart_name_or_id}` is already defined"
    end

    @result['charts'][chart_name_or_id] = Lbrt::Space::DSL::Context::Space::Chart.new(@context, @name_or_id, chart_name_or_id, &block).result
  end
end
