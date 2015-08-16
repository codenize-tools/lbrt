class Lbrt::Space::DSL::Context::Space
  def initialize(name_or_id, &block)
    @name_or_id = name_or_id
    @result = {'charts' => {}}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def chart(chart_name_or_id, &block)
    if @result[chart_name_or_id]
      raise "Space `#{@name_or_id}` > Chart `#{chart_name_or_id}` is already defined"
    end

    @result['charts'][chart_name_or_id] = Lbrt::Space::DSL::Context::Space::Chart.new(@name_or_id, chart_name_or_id, &block).result
  end
end
