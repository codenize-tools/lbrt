class Lbrt::Service::DSL::Context::Service
  REQUIRED_ATTRIBUTES = %w(
    settings
  )

  def initialize(type, title, &block)
    @type = type
    @title = title
    @result = {}
    instance_eval(&block)
  end

  def result
    REQUIRED_ATTRIBUTES.each do |name|
      unless @result.has_key?(name)
        raise "Service `#{@type}/#{@title}`: #{name} is not defined"
      end
    end

    @result
  end

  private

  def settings(value)
    unless value.is_a?(Hash)
      raise TypeError, "wrong argument type #{value.class}: #{value.inspect} (expected Hash)"
    end

    @result['settings'] = value
  end
end
