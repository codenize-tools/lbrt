class Lbrt::Service::DSL::Context::Service
  def initialize(type, title, &block)
    @type = type
    @title = title
    @result = {}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def settings(value)
    unless value.is_a?(Hash)
      raise TypeError, "wrong argument type #{value.class}: #{value.inspect} (expected Hash)"
    end

    @result['settings'] = value
  end
end
