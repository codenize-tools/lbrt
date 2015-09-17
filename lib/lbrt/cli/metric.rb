class Lbrt::CLI::Metric < Thor
  include Lbrt::Utils::CLIHelper

  class_option :target

  desc 'list', 'Show metrics'
  def list
    client(Lbrt::Metric).list
  end

  desc 'peco', 'Show metric by peco'
  def peco
    client(Lbrt::Metric).peco
  end
end
