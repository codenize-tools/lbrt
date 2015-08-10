class Lbrt::CLI::App < Thor
  desc 'alert SUBCOMMAND', 'Manage alerts'
  subcommand :alert, Lbrt::CLI::Alert

  desc 'service SUBCOMMAND', 'Manage services'
  subcommand :service, Lbrt::CLI::Service

  desc 'space SUBCOMMAND', 'Manage spaces'
  subcommand :space, Lbrt::CLI::Space
end
