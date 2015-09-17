class Lbrt::CLI::Service < Thor
  include Lbrt::Utils::CLIHelper

  class_option :target

  desc 'list', 'Show services'
  def list
    client(Lbrt::Service).list
  end

  desc 'apply FILE', 'Apply services'
  option :'dry-run', :type => :boolean, :default => false
  def apply(file)
    updated = client(Lbrt::Service).apply(file)

    unless updated
      Lbrt::Logger.instance.info('No change'.intense_blue)
    end
  end

  desc 'export [FILE]', 'Export services'
  def export(file = nil)
    dsl = client(Lbrt::Service).export

    if file.nil? or file == '-'
      puts dsl
    else
      open(file, 'wb') {|f| f.puts dsl }
    end
  end
end
