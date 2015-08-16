class Lbrt::CLI::Space < Thor
  include Lbrt::Utils::CLIHelper

  class_option :target
  class_option :'export-concurrency', :type => :numeric, :default => 32

  desc 'apply FILE', 'Apply services'
  option :'dry-run', :type => :boolean, :default => false
  def apply(file)
    updated = client(Lbrt::Space).apply(file)

    unless updated
      Lbrt::Logger.instance.info('No change'.intense_blue)
    end
  end

  desc 'export [FILE]', 'Export services'
  def export(file = nil)
    dsl = client(Lbrt::Space).export

    if file.nil? or file == '-'
      puts dsl
    else
      open(file, 'wb') {|f| f.puts dsl }
    end
  end
end
