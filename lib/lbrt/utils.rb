class Lbrt::Utils
  class << self
    def unbrace(str)
      str.sub(/\A\s*\{/, '').sub(/\}\s*\z/, '').strip
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
end
