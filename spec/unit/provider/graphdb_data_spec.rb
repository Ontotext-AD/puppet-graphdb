# frozen_string_literal: true

require 'spec_helper'
require 'puppet/util/repository_manager'
require 'puppet/util/data_type_extensions'

provider_class = Puppet::Type.type(:graphdb_data).provider(:graphdb_data)

describe provider_class do
  let(:repository_id) { 'test' }
  let(:endpoint) { 'http://test.com' }
  let(:data_format) { 'turtle' }
  let(:data) { 'test data' }
  let(:data_source) { 'test data source' }
  let(:data_context) { 'test:test' }
  let(:data_overwrite) { true }
  let(:exists_query) { 'exists query' }
  let(:exists_expected_response) { true }
  let(:timeout) { 60 }

  context 'validating data' do
    let :resource do
      Puppet::Type::Graphdb_data.new(
        name: 'foo',
        repository_id: repository_id,
        endpoint: endpoint,
        data_format: data_format,
        data: data,
        data_context: data_context,
        data_overwrite: data_overwrite,
        exists_query: exists_query,
        exists_expected_response: exists_expected_response,
        timeout: timeout
      )
    end

    let :provider do
      provider_class.new(resource)
    end

    context 'validating loaded data' do
      it 'should detect that data is loaded' do
        allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:ask)
          .with(exists_query, exists_expected_response, 0) { true }
        expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:ask)
          .with(exists_query, exists_expected_response, 0).once

        expect(provider.exists?).to be true
      end
    end

    context 'validating not loaded data' do
      it 'should detect that data is not loaded' do
        allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:ask)
          .with(exists_query, exists_expected_response, 0).and_raise(Puppet::Exceptions::RequestFailError)
        expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:ask)
          .with(exists_query, exists_expected_response, 0).once

        expect(provider.exists?).to be false
      end
    end

    context 'loading data' do
      context 'loading data with success' do
        let :resource do
          Puppet::Type::Graphdb_data.new(
            name: 'foo',
            repository_id: repository_id,
            endpoint: endpoint,
            data_format: data_format,
            data: data,
            data_context: data_context,
            data_overwrite: data_overwrite,
            exists_query: exists_query,
            exists_expected_response: exists_expected_response,
            timeout: timeout
          )
        end

        let :provider do
          provider_class.new(resource)
        end

        it 'should call load_data and return true' do
          allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with(data, data_format, data_context, data_overwrite, timeout) { true }
          expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with(data, data_format, data_context, data_overwrite, timeout).once

          expect { provider.create }.not_to raise_error
        end
      end

      context 'loading data_source' do
        context 'loading single file' do
          let :resource do
            Puppet::Type::Graphdb_data.new(
              name: 'foo',
              repository_id: repository_id,
              endpoint: endpoint,
              data_source: '/test.ttl',
              data_context: data_context,
              data_overwrite: data_overwrite,
              exists_query: exists_query,
              exists_expected_response: exists_expected_response,
              timeout: timeout
            )
          end

          let :provider do
            provider_class.new(resource)
          end

          context 'loading file with success' do
            it 'should call load_data and return true' do
              allow(File).to receive(:directory?) { false }
              allow(File).to receive(:read) { 'data_content' }
              allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content', 'turtle', data_context, data_overwrite, timeout) { true }

              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content', 'turtle', data_context, data_overwrite, timeout).once
              expect { provider.create }.not_to raise_error
            end
          end

          context 'loading file with fail' do
            context 'missing file' do
              it 'should raise error' do
                allow(File).to receive(:directory?) { false }
                allow(File).to receive(:read).and_raise('file not found')

                expect { provider.create }.to raise_error(RuntimeError, 'file not found')
              end
            end

            context 'unknown file format' do
              it 'should raise error' do
                allow(File).to receive(:directory?) { false }

                allow(Puppet::Util::DataTypeExtensions).to receive(:key?) { false }

                expect { provider.create }.to raise_error(ArgumentError, /automatic format detection fail/)
              end
            end

            context 'error while loading file' do
              it 'should raise error' do
                allow(File).to receive(:directory?) { false }
                allow(File).to receive(:read) { 'data_content' }
                allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content', 'turtle', data_context, data_overwrite, timeout)
                  .and_raise(Puppet::Exceptions::RequestFailError)

                expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content', 'turtle', data_context, data_overwrite, timeout).once

                expect { provider.create }.to raise_error(Puppet::Exceptions::RequestFailError)
              end
            end
          end
        end
        context 'loading multiple file' do
          let :resource do
            Puppet::Type::Graphdb_data.new(
              name: 'foo',
              repository_id: repository_id,
              endpoint: endpoint,
              data_source: ['/test#1.ttl', '/test#2.ttl', '/test#3.ttl'],
              data_context: data_context,
              data_overwrite: data_overwrite,
              exists_query: exists_query,
              exists_expected_response: exists_expected_response,
              timeout: timeout
            )
          end

          let :provider do
            provider_class.new(resource)
          end
          context 'with success on every file' do
            it 'should call load_data multiple times and return true' do
              allow(File).to receive(:directory?) { false }
              allow(File).to receive(:read).and_return('data_content#1', 'data_content#2', 'data_content#3')
              allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data) { true }

              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#1', 'turtle', data_context, data_overwrite, timeout).once
              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#2', 'turtle', data_context, data_overwrite, timeout).once
              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#3', 'turtle', data_context, data_overwrite, timeout).once
              expect { provider.create }.not_to raise_error
            end
          end
          context 'with fail on one file' do
            it 'should call load_data one time and raise error' do
              allow(File).to receive(:directory?) { false }
              allow(File).to receive(:read).and_return('data_content#1', 'data_content#2', 'data_content#3')
              allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#1', 'turtle', data_context, data_overwrite, timeout) { true }
              allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#2', 'turtle', data_context, data_overwrite, timeout)
                .and_raise(Puppet::Exceptions::RequestFailError)

              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#1', 'turtle', data_context, data_overwrite, timeout).once
              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#2', 'turtle', data_context, data_overwrite, timeout).once

              expect { provider.create }.to raise_error(Puppet::Exceptions::RequestFailError)
            end
          end
        end
        context 'loading directory' do
          context 'given file format' do
            let :resource do
              Puppet::Type::Graphdb_data.new(
                name: 'foo',
                repository_id: repository_id,
                endpoint: endpoint,
                data_source: '/test',
                data_format: data_format,
                data_context: data_context,
                data_overwrite: data_overwrite,
                exists_query: exists_query,
                exists_expected_response: exists_expected_response,
                timeout: timeout
              )
            end

            let :provider do
              provider_class.new(resource)
            end

            context 'with success on every file' do
              it 'should call load_data multiple times and return true' do
                allow(File).to receive(:directory?) { true }
                allow(Dir).to receive(:glob) { ['/test#1.ttl', '/test#2.ttl', '/test#3.ttl'] }
                allow(File).to receive(:read).and_return('data_content#1', 'data_content#2', 'data_content#3')
                allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data) { true }

                expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content#1', 'turtle', data_context, data_overwrite, timeout).once
                expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content#2', 'turtle', data_context, data_overwrite, timeout).once
                expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content#3', 'turtle', data_context, data_overwrite, timeout).once
                expect { provider.create }.not_to raise_error
              end
            end

            context 'with fail on single file' do
              it 'should call load_data one time and raise error' do
                allow(File).to receive(:directory?) { true }
                allow(Dir).to receive(:glob) { ['/test#1.ttl', '/test#2.ttl', '/test#3.ttl'] }
                allow(File).to receive(:read).and_return('data_content#1', 'data_content#2', 'data_content#3')
                allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content#1', 'turtle', data_context, data_overwrite, timeout) { true }
                allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content#2', 'turtle', data_context, data_overwrite, timeout)
                  .and_raise(Puppet::Exceptions::RequestFailError)

                expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content#1', 'turtle', data_context, data_overwrite, timeout).once
                expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                  .with('data_content#2', 'turtle', data_context, data_overwrite, timeout).once

                expect { provider.create }.to raise_error(Puppet::Exceptions::RequestFailError)
              end
            end
          end
          context 'with no data format provided' do
            let :resource do
              Puppet::Type::Graphdb_data.new(
                name: 'foo',
                repository_id: repository_id,
                endpoint: endpoint,
                data_source: '/test',
                data_context: data_context,
                data_overwrite: data_overwrite,
                exists_query: exists_query,
                exists_expected_response: exists_expected_response,
                timeout: timeout
              )
            end

            let :provider do
              provider_class.new(resource)
            end

            it 'should call load_data multiple times and return true' do
              allow(File).to receive(:directory?) { true }
              allow(Dir).to receive(:glob) { ['/test#1.ttl', '/test#2.ttl', '/test#3.ttl'] }
              allow(File).to receive(:read).and_return('data_content#1', 'data_content#2', 'data_content#3')
              allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data) { true }

              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#1', 'turtle', data_context, data_overwrite, timeout).once
              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#2', 'turtle', data_context, data_overwrite, timeout).once
              expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
                .with('data_content#3', 'turtle', data_context, data_overwrite, timeout).once
              expect { provider.create }.not_to raise_error
            end
          end
        end
      end

      context 'loading multi data' do
        let :resource do
          Puppet::Type::Graphdb_data.new(
            name: 'foo',
            repository_id: repository_id,
            endpoint: endpoint,
            data_format: data_format,
            data: ['test_data#1', 'test_data#2', 'test_data#3'],
            data_context: data_context,
            data_overwrite: data_overwrite,
            exists_query: exists_query,
            exists_expected_response: exists_expected_response,
            timeout: timeout
          )
        end

        let :provider do
          provider_class.new(resource)
        end

        it 'should call load_data multiple times and return true on load success for every load_data call' do
          allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data) { true }
          expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with('test_data#1', data_format, data_context, data_overwrite, timeout).once
          expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with('test_data#2', data_format, data_context, data_overwrite, timeout).once
          expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with('test_data#3', data_format, data_context, data_overwrite, timeout).once

          expect { provider.create }.not_to raise_error
        end

        it 'should call load_data multiple times and raise error on single load_data call fail' do
          allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with('test_data#1', data_format, data_context, data_overwrite, timeout) { true }
          allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with('test_data#2', data_format, data_context, data_overwrite, timeout)
            .and_raise(Puppet::Exceptions::RequestFailError)

          expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with('test_data#1', data_format, data_context, data_overwrite, timeout).once
          expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with('test_data#2', data_format, data_context, data_overwrite, timeout).once

          error_hash = { content: 'test_data#2', format: data_format, context: data_context }
          expect { provider.create }.to raise_error(Puppet::Exceptions::RequestFailError)
        end
      end

      context 'loading data with fail' do
        it 'should call load_data and raise error' do
          allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with(data, data_format, data_context, data_overwrite, timeout)
            .and_raise(Puppet::Exceptions::RequestFailError)
          expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:load_data)
            .with(data, data_format, data_context, data_overwrite, timeout).once

          error_hash = { content: data, format: data_format, context: data_context }
          expect { provider.create }.to raise_error(Puppet::Exceptions::RequestFailError)
        end
      end
    end
  end
end
