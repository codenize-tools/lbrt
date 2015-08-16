class Lbrt::Utils
  class << self
    def unbrace(str)
      str.sub(/\A\s*\{/, '').sub(/\}\s*\z/, '').strip
    end

    def matched?(str, target)
      str = str.to_s

      if target
        str =~ target
      else
        true
      end
    end
  end # of class methods

  module ContextHelper
    def require(file)
      file = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@path), file))

      if File.exist?(file)
        instance_eval(File.read(file), file)
      elsif File.exist?(file + '.rb')
        instance_eval(File.read(file + '.rb'), file + '.rb')
      else
        Kernel.require(file)
      end
    end
  end

  module CLIHelper
    def client(klass)
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

      klass.new(cli, options)
    end
  end
end
