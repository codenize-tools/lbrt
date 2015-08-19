# Lbrt

A tool to manage [Librato](https://www.librato.com/). It defines the state of [Librato](https://www.librato.com/) using DSL, and updates Librato according to DSL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lbrt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lbrt

## Usage

```sh
$ lbrt
Commands:
  lbrt alert SUBCOMMAND    # Manage alerts
  lbrt help [COMMAND]      # Describe available commands or one specific command
  lbrt metric SUBCOMMAND   # Manage metrics
  lbrt service SUBCOMMAND  # Manage services
  lbrt space SUBCOMMAND    # Manage spaces

Options:
  [--user=USER]
                           # Default: ENV['LIBRATO_USER']
  [--token=TOKEN]
                           # Default: ENV['LIBRATO_TOKEN]
  [--color], [--no-color]
                           # Default: true
  [--debug], [--no-debug]
```

```sh
$ lbrt help alert
Commands:
  lbrt alert apply FILE      # Apply alerts
  lbrt alert export [FILE]   # Export alerts
  lbrt alert help [COMMAND]  # Describe subcommands or one specific subcommand
  lbrt alert peco            # Show alert by peco

Options:
  [--target=TARGET]
```

```sh
$ brt help metric
Commands:
  lbrt metric help [COMMAND]  # Describe subcommands or one specific subcommand
  lbrt metric peco REGRXP     # Show alert by peco

Options:
  [--target=TARGET]
```

```sh
$ lbrt help service
Commands:
  lbrt service apply FILE      # Apply services
  lbrt service export [FILE]   # Export services
  lbrt service help [COMMAND]  # Describe subcommands or one specific subcommand

Options:
  [--target=TARGET]
```

```sh
$ lbrt help space
Commands:
  lbrt space apply FILE      # Apply spaces
  lbrt space export [FILE]   # Export spaces
  lbrt space help [COMMAND]  # Describe subcommands or one specific subcommand
  lbrt space peco            # Show space by peco

Options:
  [--target=TARGET]
  [--export-concurrency=N]
                            # Default: 32
```

### Export/Apply

```sh
$ lbrt space export space.rb

$ cat space.rb
space "My Space" do
  chart "My Chart" do
    type "line"
    stream do
      metric "login-delay"
      type "gauge"
      ...

$ lbrt space apply space.rb --dry-run

$ lbrt space apply space.rb
```

# DSL Example

## Sevice

```ruby
service "mail", "my email" do
  settings "addresses"=>"sugawara@example.com"
end

service "slack", "my slack" do
  settings "url"=>"https://hooks.slack.com/services/..."
end
```

## Alert

```ruby
alert "alert1" do
  description "My Alert1"
  attributes "runbook_url"=>"http://example.com"
  active true
  rearm_seconds 600
  rearm_per_signal false

  condition do
    type "below"
    metric_name "login-delay"
    source "foo.bar.com"
    threshold 1.0
    summary_function "sum"
  end

  service "mail", "my email"
end

alert "alert2" do
  description "My Alert2"
  active true
  rearm_seconds 600
  rearm_per_signal true

  condition do
    type "absent"
    metric_name "login-delay2"
    source nil
    duration 600
  end

  service "slack", "my slack"
end
```

## Space

```ruby
space "My Space1" do
  chart "chart1" do
    type "stacked"
    stream do
      metric "login-delay"
      type "gauge"
      source "*"
      group_function "average"
      summary_function "average"
    end
  end
end

space "My Space2" do
  chart "chart1" do
    type "line"
    stream do
      metric "login-delay"
      type "gauge"
      source "*"
      group_function "breakout"
      summary_function "average"
    end
  end

  chart "chart2" do
    type "line"
    stream do
      metric "login-delay2"
      type "gauge"
      source "*"
      group_function "breakout"
      summary_function "average"
    end
  end
end
```

## template

```ruby
template "dstat" do
  chart "total_cpu_usage" do
    type "stacked"
    stream do
      metric "dstat.#{context.space_name}.total_cpu_usage"
      type "gauge"
      source "*"
      group_function "breakout"
      summary_function "average"
    end
    max 100.0
  end

  chart "load_avg" do
    type "line"
    stream do
      metric "dstat.#{context.space_name}.load_avg"
      type "gauge"
      source "*"
      group_function "breakout"
      summary_function "average"
    end
  end
end

space "my-host-001" do
  include_template "dstat"
end
```

You can use the template in the `alert` and `service`.

## Show resource by [peco](https://github.com/peco/peco)

```sh
lbrt alert peco
```

```sh
lbrt metric peco
```

```sh
lbrt space peco
```

![](https://raw.githubusercontent.com/winebarrel/lbrt/master/etc/peco.gif)
