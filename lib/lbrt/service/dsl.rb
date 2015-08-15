class Lbrt::Service::DSL
  def self.convert(exported, options = {})
    Lbrt::Service::DSL::Converter.convert(exported, options)
  end

  def self.parse(dsl, path, options = {})
    Lbrt::Service::DSL::Context.eval(dsl, path, options).result
  end
end
