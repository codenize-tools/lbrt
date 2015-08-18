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

    def open(url)
      url = Shellwords.escape(url)
      cmd = ENV['LIBRATO_OPEN'] || 'open'
      system("#{cmd} #{url}")
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
    REGEXP_OPTIONS = [
      :target
    ]

    def client(klass)
      librato = Librato::Client.new(
        :user => options.delete(:user),
        :token => options.delete(:token),
        :debug => options[:debug]
      )

      String.colorize = options[:color]


      options.keys.each do |key|
        if key.to_s =~ /-/
          value = options.delete(key)
          key = key.to_s.gsub('-', '_').to_sym
          options[key] = value
        end
      end

      REGEXP_OPTIONS.each do |key|
        if options[key]
          options[key] = Regexp.new(options[key])
        end
      end

      klass.new(librato, options)
    end
  end
end
