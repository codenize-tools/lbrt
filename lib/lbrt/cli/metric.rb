class Lbrt::CLI::Metric < Thor
  include Lbrt::Utils::CLIHelper

  class_option :target

  desc 'peco', 'Show metric by peco'
  def peco
    client(Lbrt::Metric).peco
  end
end
