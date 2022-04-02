# frozen_string_literal: true

require 'spec_helper'

describe 'graphdb', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(graphdb_java_home: '/opt/jdk8')
      end

      describe 'with minimum configuration' do
        let(:params) { { version: '9.10.1', edition: 'ee' } }

        it { is_expected.to contain_package('unzip') }
        it { is_expected.to contain_user('graphdb').with(ensure: 'present', comment: 'graphdb service user') }
        it do
          is_expected.to contain_file('/opt/graphdb')
            .with(ensure: 'directory', owner: 'graphdb', group: 'graphdb')
        end
        it do
          is_expected.to contain_file('/var/tmp/graphdb')
            .with(ensure: 'directory', owner: 'graphdb', group: 'graphdb')
        end
        it do
          is_expected.to contain_file('/var/lib/graphdb')
            .with(ensure: 'directory', owner: 'graphdb', group: 'graphdb')
        end
        it { is_expected.to contain_class('graphdb::install') }
        it { is_expected.to contain_class('graphdb::tool_links') }
      end

      describe 'with custom graphdb_user and graphdb_group' do
        let(:params) { { version: '9.10.1', edition: 'ee', graphdb_user: 'user', graphdb_group: 'group' } }

        it { is_expected.to contain_file('/opt/graphdb').with(ensure: 'directory', owner: 'user', group: 'group') }
        it { is_expected.to contain_file('/var/tmp/graphdb').with(ensure: 'directory', owner: 'user', group: 'group') }
        it { is_expected.to contain_file('/var/lib/graphdb').with(ensure: 'directory', owner: 'user', group: 'group') }
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
          let(:params) { { version: '9.10.1', edition: 'ee', ensure: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'unknown status' do
          let(:params) { { version: '9.10.1', edition: 'ee', status: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not absolute data_dir path' do
          let(:params) { { version: '9.10.1', edition: 'ee', data_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not absolute tmp_dir path' do
          let(:params) { { version: '9.10.1', edition: 'ee', tmp_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not absolute install_dir path' do
          let(:params) { { version: '9.10.1', edition: 'ee', install_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not absolute import_dir path' do
          let(:params) { { version: '9.10.1', edition: 'ee', import_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid manage_graphdb_user' do
          let(:params) { { version: '9.10.1', edition: 'ee', manage_graphdb_user: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid graphdb_user' do
          let(:params) { { version: '9.10.1', edition: 'ee', graphdb_user: '' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid graphdb_group' do
          let(:params) { { version: '9.10.1', edition: 'ee', graphdb_group: '' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid purge_data_dir' do
          let(:params) { { version: '9.10.1', edition: 'ee', purge_data_dir: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid archive_dl_timeout' do
          let(:params) { { version: '9.10.1', edition: 'ee', archive_dl_timeout: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end

        context 'not valid java_home' do
          let(:params) { { version: '9.10.1', edition: 'ee', java_home: 'test' } }

          it do
            expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
          end
        end
      end
    end
  end

  context 'unknown kernel' do
    let :facts do
      {
        kernel: 'unknown',
        operatingsystem: 'Debian',
        operatingsystemmajrelease: '6'
      }
    end
    it do
      expect { is_expected.to contain_class('graphdb') }.to raise_error(Puppet::ParseError)
    end
  end

end
