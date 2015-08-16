class Lbrt::CLI::Service < Thor
  class_option :target

  desc 'apply FILE', 'Apply services'
  option :'dry-run', :type => :boolean, :default => false
  def apply(file)
    updated = client.apply(file)

    unless updated
      Lbrt::Logger.instance.info('No change'.intense_blue)
    end
  end

  desc 'export [FILE]', 'Export services'
  def export(file = nil)
    dsl = client.export

    if file.nil? or file == '-'
      puts dsl
    else
      open(file, 'wb') {|f| f.puts dsl }
    end
  end

  private

  def client
    cli = Librato::Client.new(
      :user => options.delete(:user),
      :token => options.delete(:token),
      :debug => options[:debug]
    )

    String.colorize = options[:color]
    options[:dry_run] = options.delete(:'dry-run')

    if options[:target]
      options[:target] = Regexp.new(options[:target])
    end

    Lbrt::Service.new(cli, options)
  end
end
