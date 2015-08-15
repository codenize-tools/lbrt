class Lbrt::Driver
  include Lbrt::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  # Services

  def create_service(key, expected)
    updated = false
    type, title = key
    settings = expected.fetch('settings')

    log(:info, "Create Service: #{type}/#{title}", :color => :cyan)

    unless @options[:dry_run]
      response = @client.services.post(
        'title'    => title,
        'type'     => type,
        'settings' => settings
      )

      expected['id'] = response.fetch('id')
      updated = true
    end

    updated
  end

  def delete_service(key, actual)
    updated = false
    type, title = key
    service_id = actual.fetch('id')

    log(:info, "Delete Service: #{type}/#{title}", :color => :red)

    unless @options[:dry_run]
      @client.services(service_id).delete
      updated = true
    end

    updated
  end

  def update_service(key, expected, actual)
    updated = false
    type, title = key
    service_id = actual.fetch('id')
    settings = expected.fetch('settings')

    log(:info, "Update Service: #{type}/#{title}", :color => :cyan)
    log(:info, diff(Lbrt::Service::DSL::Converter, {key => actual}, {key => expected}))

    unless @options[:dry_run]
      @client.services(service_id).put(
        'settings' => settings
      )

      updated = true
    end

    updated
  end

  private

  def diff(converter, obj1, obj2)
    diffy = Diffy::Diff.new(
      converter.convert(obj1),
      converter.convert(obj2),
      :diff => '-u'
    )

    diffy.to_s(@options[:color] ? :color : :text).gsub(/\s+\z/m, '')
  end
end
