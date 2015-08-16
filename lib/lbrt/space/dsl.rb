class Lbrt::Space::DSL
  def self.convert(exported, options = {})
    Lbrt::Space::DSL::Converter.convert(exported, options)
  end

  def self.parse(dsl, path, options = {})
    Lbrt::Space::DSL::Context.eval(dsl, path, options).result
  end
end
