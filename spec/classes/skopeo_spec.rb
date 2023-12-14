# frozen_string_literal: true

require 'spec_helper'

describe 'skopeo' do
  _, os_facts = on_supported_os.first
  let(:facts) { os_facts }

  context 'with default parameters' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('skopeo') }
    it { is_expected.to contain_class('skopeo::install') }
    it { is_expected.to contain_class('skopeo::config') }
    it { is_expected.to contain_user('skopeo').with(ensure: 'present') }
    it { is_expected.to contain_group('skopeo').with(ensure: 'present') }
    it { is_expected.to contain_package('skopeo').with_ensure(%r{present|installed}) }
    it { is_expected.to contain_file('/var/log/skopeo').with(ensure: 'directory') }
  end

  context 'with dest prefix' do
    let(:params) do
      {
        sync: {
          registry: {
            src: 'registry.k8s.io',
            dest: 'local.reg',
            dest_prefix: 'k8s.io',
          }
        }
      }
    end

    it { is_expected.to compile.with_all_deps }
    yaml_config = <<~YAML
    ---
    registry.k8s.io:
      tls-verify: true
    YAML
    it {
      is_expected.to contain_file('/home/skopeo/registry.yaml')
        .with(
          ensure: 'file',
          content: yaml_config,
        )
    }

    cmd = 'skopeo sync --src yaml --dest docker /home/skopeo/registry.yaml local.reg/k8s.io >> /var/log/skopeo/skopeo.log 2>&1'
    it { is_expected.to contain_exec('skopeo_sync-registry').with(command: cmd) }
  end

  context 'with matrix' do
    let(:params) do
      {
        sync: {
          registry: {
            tls_verify: false,
            src: 'registry.k8s.io',
            dest: 'local.reg',
            matrix: {
              images: ['pause'],
              versions: ['3.8', '3.9'],
            },
            on_change: false,
          }
        }
      }
    end

    it { is_expected.to compile.with_all_deps }
    yaml_config = <<~YAML
    ---
    registry.k8s.io:
      tls-verify: false
      images:
        pause:
        - '3.8'
        - '3.9'
    YAML
    it {
      is_expected.to contain_file('/home/skopeo/registry.yaml')
        .with(
          ensure: 'file',
          content: yaml_config,
        )
    }

    cmd = 'skopeo sync --src yaml --dest docker /home/skopeo/registry.yaml local.reg/k8s.io >> /var/log/skopeo/skopeo.log 2>&1'
    it { is_expected.not_to contain_exec('skopeo_sync-registry').with(command: cmd) }
  end
end
