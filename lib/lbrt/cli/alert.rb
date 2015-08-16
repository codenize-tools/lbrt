class Lbrt::CLI::Alert < Thor
  include Lbrt::Utils::CLIHelper

  class_option :target

  desc 'apply FILE', 'Apply alerts'
  option :'dry-run', :type => :boolean, :default => false
  def apply(file)
    updated = client(Lbrt::Alert).apply(file)

    unless updated
      Lbrt::Logger.instance.info('No change'.intense_blue)
    end
  end

  desc 'export [FILE]', 'Export alerts'
  def export(file = nil)
    dsl = client(Lbrt::Alert).export

    if file.nil? or file == '-'
      puts dsl
    else
      open(file, 'wb') {|f| f.puts dsl }
    end
  end
end
