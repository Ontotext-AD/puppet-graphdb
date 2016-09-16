require 'spec_helper'

describe 'graphdb', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(machine_java_home: '/opt/jdk7')
      end

      describe 'with minimum configuration' do
        let(:params) { { version: '7.0.0', edition: 'ee' } }

        it do
          is_expected.to contain_class('graphdb::params')
          is_expected.to contain_anchor('graphdb::begin')
          is_expected.to contain_package('unzip')
          is_expected.to contain_user('graphdb').with(ensure: 'present', comment: 'graphdb service user')
          is_expected.to contain_file('/opt/graphdb').with(ensure: 'directory', owner: 'graphdb', group: 'graphdb')
          is_expected.to contain_file('/var/tmp/graphdb').with(ensure: 'directory', owner: 'graphdb', group: 'graphdb')
          is_expected.to contain_file('/var/lib/graphdb').with(ensure: 'directory', owner: 'graphdb', group: 'graphdb')
          is_expected.to contain_class('graphdb::install')
          is_expected.to contain_class('graphdb::tool_links')
        end
      end

      describe 'with custom graphdb_user and graphdb_group' do
        let(:params) { { version: '7.0.0', edition: 'ee', graphdb_user: 'user', graphdb_group: 'group' } }

        it do
          is_expected.to contain_file('/opt/graphdb').with(ensure: 'directory', owner: 'user', group: 'group')
          is_expected.to contain_file('/var/tmp/graphdb').with(ensure: 'directory', owner: 'user', group: 'group')
          is_expected.to contain_file('/var/lib/graphdb').with(ensure: 'directory', owner: 'user', group: 'group')
        end
      end

      describe 'with wrong configuration' do
        context 'unsupported version' do
          let(:params) { { version: '6.0.0', edition: 'ee' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'unknown edition' do
          let(:params) { { version: '6.0.0', edition: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'unknown ensure' do
          let(:params) { { version: '7.0.0', edition: 'ee', ensure: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'unknown status' do
          let(:params) { { version: '7.0.0', edition: 'ee', status: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not absolute data_dir path' do
          let(:params) { { version: '7.0.0', edition: 'ee', data_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not absolute tmp_dir path' do
          let(:params) { { version: '7.0.0', edition: 'ee', tmp_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not absolute install_dir path' do
          let(:params) { { version: '7.0.0', edition: 'ee', install_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid manage_graphdb_user' do
          let(:params) { { version: '7.0.0', edition: 'ee', manage_graphdb_user: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid graphdb_user' do
          let(:params) { { version: '7.0.0', edition: 'ee', graphdb_user: '' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid graphdb_group' do
          let(:params) { { version: '7.0.0', edition: 'ee', graphdb_group: '' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid purge_data_dir' do
          let(:params) { { version: '7.0.0', edition: 'ee', purge_data_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid archive_dl_timeout' do
          let(:params) { { version: '7.0.0', edition: 'ee', archive_dl_timeout: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid java_home' do
          let(:params) { { version: '7.0.0', edition: 'ee', java_home: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end
      end
    end
  end
end
