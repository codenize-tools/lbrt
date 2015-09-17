class Lbrt::CLI::Space < Thor
  include Lbrt::Utils::CLIHelper

  class_option :target
  class_option :'concurrency', :type => :numeric, :default => 32

  desc 'list', 'Show spaces'
  def list
    client(Lbrt::Space).list
  end

  desc 'peco', 'Show space by peco'
  def peco
    client(Lbrt::Space).peco
  end

  desc 'apply FILE', 'Apply spaces'
  option :'dry-run', :type => :boolean, :default => false
  option :'ignore-no-metric', :type => :boolean, :default => true
  def apply(file)
    updated = client(Lbrt::Space).apply(file)

    unless updated
      Lbrt::Logger.instance.info('No change'.intense_blue)
    end
  end

  desc 'export [FILE]', 'Export spaces'
  def export(file = nil)
    dsl = client(Lbrt::Space).export

    if file.nil? or file == '-'
      puts dsl
    else
      open(file, 'wb') {|f| f.puts dsl }
    end
  end
end
