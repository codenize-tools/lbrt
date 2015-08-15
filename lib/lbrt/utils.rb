class Lbrt::Utils
  class << self
    def unbrace(str)
      str.sub(/\A\s*\{/, '').sub(/\}\s*\z/, '').strip
    end
  end # of class methods
end
