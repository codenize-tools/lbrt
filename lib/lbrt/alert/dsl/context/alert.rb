class Lbrt::Alert::DSL::Context::Alert
  REQUIRED_ATTRIBUTES = %w(
    description
    attributes
    active
    rearm_seconds
    rearm_per_signal
  )

  def initialize(name, services, &block)
    @name = name
    @services = services

    @result = {
      'attributes' => {},
      'conditions' => [],
      'services' => [],
    }

    instance_eval(&block)
  end

  def result
    REQUIRED_ATTRIBUTES.each do |name|
      unless @result.has_key?(name)
        raise "Alert `#{@name}`: #{name} is not defined"
      end
    end

    @result
  end

  private

  def description(value)
    @result['description'] = value.to_s
  end

  def attributes(value)
    unless value.is_a?(Hash)
      raise TypeError, "wrong argument type #{value.class}: #{value.inspect} (expected Hash)"
    end

    @result['attributes'] = value
  end

  def active(value)
    @result['active'] = !!value
  end

  def rearm_seconds(value)
    @result['rearm_seconds'] = value.to_i
  end

  def rearm_per_signal(value)
    @result['rearm_per_signal'] = !!value
  end

  def condition(&block)
    @result['conditions'] << Lbrt::Alert::DSL::Context::Alert::Condition.new(@name, &block).result
  end

  def service(type, title)
    service_key = [type, title]
    service = @services[service_key]

    unless service
      raise "Service `#{type}/#{title}` is not found"
    end

    @result['services'] << service
  end
end
