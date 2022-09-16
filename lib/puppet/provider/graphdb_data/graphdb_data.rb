# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/repository_manager'
require 'puppet/util/data_type_extensions'
require 'puppet/exceptions/request_fail'

Puppet::Type.type(:graphdb_data).provide(:graphdb_data) do
  desc "A provider for the resource type `graphdb_data`,
  which loads data into given GraphDB repository"

  def exists?
    Puppet.debug 'Check whether data is already loaded'
    repository_manager.ask(resource[:exists_query], resource[:exists_expected_response], 0)
    true
  rescue Puppet::Exceptions::RequestFailError
    false
  end

  def create
    if resource[:data].nil?
      handle_data_source(resource[:data_source])
    else
      handle_data(resource[:data])
    end
  end

  private

  def handle_data(data)
    data.each do |curr_data|
      repository_manager.load_data(curr_data[:content],
                                   curr_data[:format],
                                   curr_data[:context],
                                   resource[:data_overwrite],
                                   resource[:timeout])
    end
  end

  def handle_data_source(data_sources)
    data_sources.each do |data_source|
      if File.directory?(data_source[:source])
        handle_data_directory(data_source)
      else
        handle_data_file(data_source)
      end
    end
    true
  end

  def handle_data_directory(directory)
    Dir.glob(directory[:source] + '/**/*').each do |file|
      format = if directory.key?(:format) && !directory[:format].nil?
                 directory[:format]
               else
                 resolve_file_format(file)
               end
      repository_manager.load_data(File.read(file),
                                   format,
                                   directory[:context],
                                   resource[:data_overwrite],
                                   resource[:timeout])
    end
  end

  def handle_data_file(file)
    format = !file.key?(:format) || file[:format].nil? ? resolve_file_format(file[:source]) : file[:format]
    repository_manager.load_data(File.read(file[:source]),
                                 format,
                                 file[:context],
                                 resource[:data_overwrite],
                                 resource[:timeout])
  end

  def resolve_file_format(file_path)
    file_extension = File.extname(file_path)
    unless Puppet::Util::DataTypeExtensions.key?(file_extension)
      raise(ArgumentError, "automatic format detection fail for [#{file_path}],
	   															you should provide per source format or data_format")
    end
    Puppet::Util::DataTypeExtensions[file_extension]
  end

  def repository_manager
    @repository_manager ||= Puppet::Util::RepositoryManager.new(resource[:endpoint], resource[:repository_id])
  end
end
