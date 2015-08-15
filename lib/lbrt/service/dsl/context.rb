class Lbrt::Service::DSL::Context
  def self.eval(dsl, path, options = {})
    self.new(path, options) {
      eval(dsl, binding, path)
    }
  end

  attr_reader :result

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @result = {}
    instance_eval(&block)
  end

  private

  def require(file)
    file = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@path), file))

    if File.exist?(file)
      instance_eval(File.read(file), file)
    elsif File.exist?(file + '.rb')
      instance_eval(File.read(file + '.rb'), file + '.rb')
    else
      Kernel.require(file)
    end
  end

  def service(type, title, &block)
    type = type.to_s
    title = title.to_s
    key = [type, title]

    if @result[key]
      raise "Service `#{type}/#{title}` is already defined"
    end

    service = Lbrt::Service::DSL::Context::Service.new(type, title, &block).result
    @result[key] = service
  end
end
