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
end
