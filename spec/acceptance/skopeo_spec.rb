# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

describe 'skopei' do
  context 'basic setup' do
    it 'install skopeo' do
      pp = <<~EOS
        class { 'skopeo':
          sync => {
            'k8s' => {
              src => 'registry.k8s.io',
              dest => '/home/skopeo/local',
              matrix => {
                'images' => ['pause'],
                'versions' => ['3.8','3.9'],
              }
            }
          }
        }
      EOS

      # first run seems to exit with code 6 (systemd reload)
      apply_manifest(pp, catch_failures: false)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/home/skopeo') do
      it { is_expected.to be_directory }
      it { is_expected.to be_readable.by('owner') }
    end

    describe file('/home/skopeo/k8s.yaml') do
      it { is_expected.to be_file }
      it { is_expected.to be_readable.by('owner') }
      it { is_expected.to be_readable.by('group') }
    end

    describe file('/home/skopeo/local') do
      it { is_expected.to be_directory }
      it { is_expected.to be_readable.by('owner') }
    end
  end
end
