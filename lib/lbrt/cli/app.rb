class Lbrt::CLI::App < Thor
  class_option :user,  :default => ENV['LIBRATO_USER']
  class_option :token, :default => ENV['LIBRATO_TOKEN']
  class_option :color, :type => :boolean, :default => true
  class_option :debug, :type => :boolean, :default => false

  desc 'alert SUBCOMMAND', 'Manage alerts'
  subcommand :alert, Lbrt::CLI::Alert

  desc 'service SUBCOMMAND', 'Manage services'
  subcommand :service, Lbrt::CLI::Service

  desc 'space SUBCOMMAND', 'Manage spaces'
  subcommand :space, Lbrt::CLI::Space
end
