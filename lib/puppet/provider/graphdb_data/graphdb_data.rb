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
    if !resource[:data].nil?
      resource[:data].each do |data|
        repository_manager.load_data(data[:content], data[:format], data[:context], resource[:data_overwrite], resource[:timeout])
      end
    else
      resource[:data_source].each do |data_source|
        if File.directory?(data_source[:source])
          Dir.glob(data_source[:source] + '/**/*').each do |file|
            format = !data_source.key?(:format) || data_source[:data_format].nil? ? resolve_file_format(file) : data_source[:data_format]
            repository_manager.load_data(File.read(file), format, data_source[:context], resource[:data_overwrite], resource[:timeout])
          end
        else
          format = !data_source.key?(:format) || data_source[:data_format].nil? ? resolve_file_format(data_source[:source]) : data_source[:data_format]
          repository_manager.load_data(File.read(data_source[:source]), format, data_source[:context], resource[:data_overwrite], resource[:timeout])
        end
      end
    end
  end

private

  def resolve_file_format(file_path)
    if !get_file_format(file_path).nil?
      return get_file_format(file_path)
    else
      raise "automatic format detection fail for [#{file_path}], you should provide per source format or data_format"
    end
  end

  def get_file_format(file_path)
    file_extension = File.extname(file_path)
    Puppet::Util::DataTypeExtensions.key?(file_extension) ? Puppet::Util::DataTypeExtensions[file_extension] : nil
  end

  def repository_manager
    @repository_manager ||= Puppet::Util::RepositoryManager.new(resource[:endpoint], resource[:repository_id])
  end
end
