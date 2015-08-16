class Lbrt::Service
  include Lbrt::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
    @driver = Lbrt::Driver.new(@client, @options)
  end

  def export(export_options = {})
    exported = Lbrt::Service::Exporter.export(@client, @options)
    Lbrt::Service::DSL.convert(exported, @options)
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    expected = load_file(file)
    actual = Lbrt::Service::Exporter.export(@client, @options)
    walk_services(expected, actual)
  end

  def walk_services(expected, actual)
    updated = false

    expected.each do |key, expected_service|
      actual_service = actual.delete(key)

      if actual_service
        updated = walk_service(key, expected_service, actual_service) || updated
      else
        updated = @driver.create_service(key, expected_service) || updated
      end
    end

    actual.each do |key, actual_service|
      updated = @driver.delete_service(key, actual_service) || updated
    end

    updated
  end

  def walk_service(key, expected, actual)
    updated = false

    actual_without_id = actual.dup
    service_id = actual_without_id.delete('id')

    if expected != actual_without_id
      updated = @driver.update_service(key, expected.merge('id' => service_id), actual) || updated
    end

    updated
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Lbrt::Service::DSL.parse(f.read, file)
      end
    elsif [File, Tempfile].any? {|i| file.kind_of?(i) }
      Lbrt::Service::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
