$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/repository_manager'
require 'puppet/util/data_type_extensions'

Puppet::Type.type(:graphdb_data).provide(:graphdb_data) do
  desc "A provider for the resource type `graphdb_data`,
  which loads data into given GraphDB repository"

  def exists?
    Puppet.debug 'Check whether data is already loaded'
    repository_manager.ask(resource[:exists_query], resource[:exists_expected_response], 0)
  end

  def create
    handle_data(resource[:data]) unless resource[:data].nil?
    handle_data_source(resource[:data_source])
  end

private

  def handle_data(data)
    call_load_data(data[:content], data[:format])
  end

  def handle_data_source(data_sources)
    data_sources.each do |data_source|
      handle_data_directory(data_source[:source]) if File.directory?(data_source[:source])
      handle_data_file(data_source)
    end
  end

  def handle_data_directory(directory)
    Dir.glob(directory + '/**/*').each do |file|
      format = if directory.key?(:format) && !directory[:data_format].nil?
                 directory[:data_format]
               else
                 resolve_file_format(file)
               end
      repository_manager.load_data(File.read(file), format)
    end
  end

  def handle_data_file(file)
    format = !file.key?(:format) || file[:data_format].nil? ? resolve_file_format(file[:source]) : file[:data_format]
    repository_manager.load_data(File.read(file[:source]), format)
  end

  def call_load_data(data, data_format)
    repository_manager.load_data(data,
                                 data_format,
                                 data_source[:context],
                                 resource[:data_overwrite],
                                 resource[:timeout])
  end

  def resolve_file_format(file_path)
    return get_file_format(file_path) unless get_file_format(file_path).nil?
    raise "automatic format detection fail for [#{file_path}], you should provide per source format or data_format"
  end

  def get_file_format(file_path)
    file_extension = File.extname(file_path)
    Puppet::Util::DataTypeExtensions.key?(file_extension) ? Puppet::Util::DataTypeExtensions[file_extension] : nil
  end

  def repository_manager
    @repository_manager ||= Puppet::Util::RepositoryManager.new(resource[:endpoint], resource[:repository_id])
  end
end
