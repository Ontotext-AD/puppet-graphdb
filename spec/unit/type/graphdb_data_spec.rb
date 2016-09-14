require 'spec_helper'

describe Puppet::Type.type(:graphdb_data) do
  let(:repository_id) { 'test' }
  let(:endpoint) { 'http://test.com' }
  let(:data_format) { 'turtle' }
  let(:data_context) { 'test:test' }
  let(:data) { 'data' }
  let(:data_source) { '/data.ttl' }
  let(:data_overwrite) { true }
  let(:exists_query) { 'exists query' }
  let(:exists_expected_response) { true }
  let(:timeout) { '60' }

  context 'with all needed params' do
    let :graphdb_data do
      Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                           repository_id: repository_id,
                                           endpoint: endpoint,
                                           data_format: data_format,
                                           data_context: data_context,
                                           data: data,
                                           data_overwrite: data_overwrite,
                                           exists_query: exists_query,
                                           exists_expected_response: exists_expected_response,
                                           timeout: timeout)
    end

    it 'should pass munge on every param' do
      expect(graphdb_data[:endpoint]).to eq(URI(endpoint))
      expect(graphdb_data[:timeout]).to eq(Integer(timeout))
    end
  end

  context 'with both data and data_source' do
    it do
      expect do
        Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                             repository_id: repository_id,
                                             endpoint: endpoint,
                                             data_format: data_format,
                                             data_context: data_context,
                                             data: data,
                                             data_source: data_source,
                                             data_overwrite: data_overwrite,
                                             exists_query: exists_query,
                                             exists_expected_response: exists_expected_response,
                                             timeout: timeout)
      end
        .to raise_error(Puppet::ResourceError, /you shoud pass data or data_source, not both/)
    end
  end

  context 'with no repository_id provided' do
    let :graphdb_data do
      Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                           endpoint: endpoint,
                                           data_format: data_format,
                                           data_context: data_context,
                                           data: data,
                                           data_overwrite: data_overwrite,
                                           exists_query: exists_query,
                                           exists_expected_response: exists_expected_response,
                                           timeout: timeout)
    end

    it do
      expect(graphdb_data[:repository_id]).to eq(graphdb_data[:name])
    end
  end

  context 'with not valid endpoint' do
    it do
      expect do
        Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                             endpoint: 'not valid uri',
                                             data_format: data_format,
                                             data_context: data_context,
                                             data: data,
                                             data_overwrite: data_overwrite,
                                             exists_query: exists_query,
                                             exists_expected_response: exists_expected_response,
                                             timeout: timeout)
      end
        .to raise_error(Puppet::ResourceError, /endpoint should be valid url: not valid uri/)
    end
  end

  context 'with not valid data context' do
    it do
      expect do
        Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                             endpoint: endpoint,
                                             data_format: data_format,
                                             data_context: 'not valid data context',
                                             data: data,
                                             data_overwrite: data_overwrite,
                                             exists_query: exists_query,
                                             exists_expected_response: exists_expected_response,
                                             timeout: timeout)
      end
        .to raise_error(Puppet::ResourceError, /data_context should be valid uri: not valid data context/)
    end
  end

  context 'with not valid timeout' do
    it do
      expect do
        Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                             endpoint: endpoint,
                                             data_format: data_format,
                                             data_context: data_context,
                                             data: data,
                                             data_overwrite: data_overwrite,
                                             exists_query: exists_query,
                                             exists_expected_response: exists_expected_response,
                                             timeout: 'not valid timeout')
      end
        .to raise_error(Puppet::ResourceError, /timeout should be valid integer: not valid timeout/)
    end
  end

  context 'with data provided' do
    context 'with single data provided' do
      let :graphdb_data do
        Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                             repository_id: repository_id,
                                             endpoint: endpoint,
                                             data_format: data_format,
                                             data_context: data_context,
                                             data: data,
                                             data_overwrite: data_overwrite,
                                             exists_query: exists_query,
                                             exists_expected_response: exists_expected_response,
                                             timeout: timeout)
      end
      it 'should pass munge on every param' do
        expect(graphdb_data[:data]).to eq([{ content: data, format: data_format, context: data_context }])
      end
    end

    context 'with unsupported data provided' do
      it do
        expect do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data_format: data_format,
                                               data_context: data_context,
                                               data: 192,
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end.to raise_error(Puppet::ResourceError, /data should be string or array: 192/)
      end
    end

    context 'with data provided as array' do
      context 'with data_format' do
        let :graphdb_data do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data: [data, data],
                                               data_format: data_format,
                                               data_context: data_context,
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end
        it 'should pass munge on every param' do
          expect(graphdb_data[:data]).to eq([{ content: data, format: data_format, context: data_context },
                                             { content: data, format: data_format, context: data_context }])
        end
      end

      context 'with no data_format' do
        it do
          expect do
            Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                                 repository_id: repository_id,
                                                 endpoint: endpoint,
                                                 data: [data, data],
                                                 data_context: data_context,
                                                 data_overwrite: data_overwrite,
                                                 exists_query: exists_query,
                                                 exists_expected_response: exists_expected_response,
                                                 timeout: timeout)
          end
            .to raise_error(Puppet::ResourceError, /you should pass data_format/)
        end
      end

      context 'with no data_context' do
        let :graphdb_data do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data: [data, data],
                                               data_format: data_format,
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end
        it do
          expect(graphdb_data[:data]).to eq(
            [{ content: data, format: 'turtle', context: nil }, { content: data, format: 'turtle', context: nil }]
          )
        end
      end
    end

    context 'with data provided as array of hashes' do
      context 'format and context provided in the hashes' do
        let :graphdb_data do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data: [{ 'content' => data,
                                                        'context' => data_context,
                                                        'format' => data_format },
                                                      { 'content' => data,
                                                        'context' => data_context,
                                                        'format' => data_format }],
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end
        it 'should pass munge on every param' do
          expect(graphdb_data[:data]).to eq([{ content: data, format: data_format, context: data_context },
                                             { content: data, format: data_format, context: data_context }])
        end
      end

      context 'with no format and context in the hashes' do
        context 'with format and context provided for the graphdb_data' do
          let :graphdb_data do
            Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                                 repository_id: repository_id,
                                                 endpoint: endpoint,
                                                 data: [{ 'content' => data },
                                                        { 'content' => data }],
                                                 data_format: data_format,
                                                 data_context: data_context,
                                                 data_overwrite: data_overwrite,
                                                 exists_query: exists_query,
                                                 exists_expected_response: exists_expected_response,
                                                 timeout: timeout)
          end
          it 'should pass munge on every param' do
            expect(graphdb_data[:data]).to eq([{ content: data, format: data_format, context: data_context },
                                               { content: data, format: data_format, context: data_context }])
          end
        end

        context 'no format provided for the graphdb_data' do
          it do
            expect do
              Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                                   repository_id: repository_id,
                                                   endpoint: endpoint,
                                                   data: [{ 'content' => data },
                                                          { 'content' => data }],
                                                   data_context: data_context,
                                                   data_overwrite: data_overwrite,
                                                   exists_query: exists_query,
                                                   exists_expected_response: exists_expected_response,
                                                   timeout: timeout)
            end.to raise_error(Puppet::ResourceError,
                               /you should provide data format for data through format or data_format/)
          end
        end

        context 'no context provided for the graphdb_data' do
          let :graphdb_data do
            Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                                 repository_id: repository_id,
                                                 endpoint: endpoint,
                                                 data: [{ 'content' => data },
                                                        { 'content' => data }],
                                                 data_format: data_format,
                                                 data_overwrite: data_overwrite,
                                                 exists_query: exists_query,
                                                 exists_expected_response: exists_expected_response,
                                                 timeout: timeout)
          end
          it 'should pass munge on every param' do
            expect(graphdb_data[:data]).to eq([{ content: data, format: data_format, context: nil },
                                               { content: data, format: data_format, context: nil }])
          end
        end
      end
    end
  end

  context 'with data_source provided' do
    context 'with single data_source provided' do
      let :graphdb_data do
        Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                             repository_id: repository_id,
                                             endpoint: endpoint,
                                             data_format: data_format,
                                             data_context: data_context,
                                             data_source: data_source,
                                             data_overwrite: data_overwrite,
                                             exists_query: exists_query,
                                             exists_expected_response: exists_expected_response,
                                             timeout: timeout)
      end
      it 'should pass munge on every param' do
        expect(graphdb_data[:data_source]).to eq([{ source: data_source, format: data_format, context: data_context }])
      end
    end

    context 'with unsupported data_source provided' do
      it do
        expect do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data_format: data_format,
                                               data_context: data_context,
                                               data_source: 192,
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end.to raise_error(Puppet::ResourceError, /data_source should be string or array: 192/)
      end
      it do
        expect do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data_format: data_format,
                                               data_context: data_context,
                                               data_source: 'test',
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end.to raise_error(Puppet::ResourceError, /test is not absolute path/)
      end
    end

    context 'with data_source provided as array' do
      context 'with data_format' do
        let :graphdb_data do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data_source: [data_source, data_source],
                                               data_format: data_format,
                                               data_context: data_context,
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end
        it 'should pass munge on every param' do
          expect(graphdb_data[:data_source]).to eq(
            [{ source: data_source, format: data_format, context: data_context },
             { source: data_source, format: data_format, context: data_context }]
          )
        end
      end

      context 'with no data_format' do
        let(:graphdb_data) do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data_source: [data_source, data_source],
                                               data_context: data_context,
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end

        it do
          expect(graphdb_data[:data_source]).to eq([{ source: data_source, format: nil, context: data_context },
                                                    { source: data_source, format: nil, context: data_context }])
        end
      end

      context 'with no data_context' do
        let :graphdb_data do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data_source: [data_source, data_source],
                                               data_format: data_format,
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end
        it do
          expect(graphdb_data[:data_source]).to eq(
            [{ source: data_source, format: 'turtle', context: nil },
             { source: data_source, format: 'turtle', context: nil }]
          )
        end
      end
    end

    context 'with data_source provided as array of hashes' do
      context 'with source in hash' do
        it do
          expect do
            Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                                 repository_id: repository_id,
                                                 endpoint: endpoint,
                                                 data_source: [{}, {}],
                                                 data_format: data_format,
                                                 data_context: data_context,
                                                 data_overwrite: data_overwrite,
                                                 exists_query: exists_query,
                                                 exists_expected_response: exists_expected_response,
                                                 timeout: timeout)
          end.to raise_error(Puppet::ResourceError, /you should provide source through source/)
        end
      end

      context 'with not valid source in hash' do
        it do
          expect do
            Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                                 repository_id: repository_id,
                                                 endpoint: endpoint,
                                                 data_source: [{ 'source' => 'test' }],
                                                 data_format: data_format,
                                                 data_context: data_context,
                                                 data_overwrite: data_overwrite,
                                                 exists_query: exists_query,
                                                 exists_expected_response: exists_expected_response,
                                                 timeout: timeout)
          end.to raise_error(Puppet::ResourceError, /test is not absolute path/)
        end
      end

      context 'with no format and context in hash' do
        let :graphdb_data do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data_source: [{ 'source' => data_source },
                                                             { 'source' => data_source }],
                                               data_format: data_format,
                                               data_context: data_context,
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end
        it do
          expect(graphdb_data[:data_source]).to eq(
            [{ source: data_source, format: data_format, context: data_context },
             { source: data_source, format: data_format, context: data_context }]
          )
        end
      end

      context 'with format and context in hash' do
        let :graphdb_data do
          Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               data_source: [{ 'source' => data_source,
                                                               'format' => data_format,
                                                               'context' => data_context },
                                                             { 'source' => data_source,
                                                               'format' => data_format,
                                                               'context' => data_context }],
                                               data_overwrite: data_overwrite,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
        end
        it do
          expect(graphdb_data[:data_source]).to eq(
            [{ source: data_source, format: data_format, context: data_context },
             { source: data_source, format: data_format, context: data_context }]
          )
        end
      end
    end
  end

  it 'should autorequire graphdb_repository if endpoint and http_port matches' do
    catalog = Puppet::Resource::Catalog.new
    graphdb_repository = Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                                    endpoint: endpoint,
                                                                    repository_id: repository_id)
    graphdb_data = Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                                        repository_id: repository_id,
                                                        endpoint: endpoint,
                                                        data_format: data_format,
                                                        data_context: data_context,
                                                        data: data,
                                                        data_overwrite: data_overwrite,
                                                        exists_query: exists_query,
                                                        exists_expected_response: exists_expected_response,
                                                        timeout: timeout)

    catalog.add_resource graphdb_repository
    catalog.add_resource graphdb_data

    relationship = graphdb_data.autorequire.find do |rel|
      (rel.source.to_s == 'Graphdb_repository[foo]') && (rel.target.to_s == graphdb_data.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it 'should not autorequire any graphdb_repository if it is not managed' do
    catalog = Puppet::Resource::Catalog.new
    graphdb_data = Puppet::Type.type(:graphdb_data).new(name: 'foo',
                                                        repository_id: repository_id,
                                                        endpoint: endpoint,
                                                        data_format: data_format,
                                                        data_context: data_context,
                                                        data: data,
                                                        data_overwrite: data_overwrite,
                                                        exists_query: exists_query,
                                                        exists_expected_response: exists_expected_response,
                                                        timeout: timeout)
    catalog.add_resource graphdb_data
    expect(graphdb_data.autorequire).to be_empty
  end
end
