class Lbrt::Alert::DSL
  def self.convert(exported, options = {})
    Lbrt::Alert::DSL::Converter.convert(exported, options)
  end

  def self.parse(client, dsl, path, options = {})
    Lbrt::Alert::DSL::Context.eval(client, dsl, path, options).result
  end
end
