# frozen_string_literal: true

require 'spec_helper'

describe 'skopeo::sync' do
  _, os_facts = on_supported_os.first
  let(:title) { 'registry' }
  let(:facts) { os_facts }
  let :pre_condition do
    'include skopeo'
  end

  context 'with defined matrix' do
    let(:params) do
      {
        src: 'registry.k8s.io',
        dest: 'local.reg',
        matrix: {
          images: ['kube-apiserver', 'kube-controller-manager'],
          versions: ['1.27.1', '1.28.2'],
        }
      }
    end

    it { is_expected.to compile.with_all_deps }
    yaml_config = <<~YAML
    ---
    registry.k8s.io:
      tls-verify: true
      images:
        kube-apiserver:
        - 1.27.1
        - 1.28.2
        kube-controller-manager:
        - 1.27.1
        - 1.28.2
    YAML
    it {
      is_expected.to contain_file('/home/skopeo/registry.yaml')
        .with(
          ensure: 'file',
          content: yaml_config,
        )
    }

    it {
      is_expected.to contain_exec('skopeo_sync-registry').with(
      command: 'skopeo sync --src yaml --dest docker /home/skopeo/registry.yaml local.reg >> /var/log/skopeo/skopeo.log 2>&1',
    )
    }
  end

  context 'with dest prefix' do
    let(:params) do
      {
        src: 'registry.k8s.io',
        dest: 'local.reg',
        dest_prefix: 'k8s.io',
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

    it { is_expected.to contain_exec('skopeo_sync-registry').with(
      command: 'skopeo sync --src yaml --dest docker /home/skopeo/registry.yaml local.reg/k8s.io >> /var/log/skopeo/skopeo.log 2>&1',
    ) }
  end

  context 'with by tag images' do
    let(:params) do
      {
        src: 'registry.k8s.io',
        dest: 'local.reg',
        by_tag: {
          'pause' => '^3\.(8|9)$'
        },
        tls_verify: false,
      }
    end

    it { is_expected.to compile.with_all_deps }

    yaml_config = <<~YAML
    ---
    registry.k8s.io:
      tls-verify: false
      images-by-tag-regex:
        pause: "^3\\\\.(8|9)$"
    YAML
    it {
      is_expected.to contain_file('/home/skopeo/registry.yaml')
        .with(
          ensure: 'file',
          content: yaml_config,
        )
    }

    it { is_expected.to contain_exec('skopeo_sync-registry').with(
      command: 'skopeo sync --src yaml --dest docker /home/skopeo/registry.yaml local.reg >> /var/log/skopeo/skopeo.log 2>&1',
    ) }
  end
end
