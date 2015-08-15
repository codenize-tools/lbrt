class Lbrt::Alert::DSL::Context
  def self.eval(client, dsl, path, options = {})
    self.new(client, path, options) {
      eval(dsl, binding, path)
    }
  end

  attr_reader :result

  def initialize(client, path, options = {}, &block)
    @path = path
    @options = options
    @result = {}
    @services = Lbrt::Service::Exporter.export(client, options)
    instance_eval(&block)
  end

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

  def alert(name, &block)
    name = name.to_s

    if @result[name]
      raise "Alert `#{name}` is already defined"
    end

    alert = Lbrt::Alert::DSL::Context::Alert.new(name, @services, &block).result
    @result[name] = alert
  end
end
