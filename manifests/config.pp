# @summary Manage common configuration
# @api private
class skopeo::config {
  user { $skopeo::user:
    ensure     => present,
    managehome => true,
    shell      => '/bin/bash',
    uid        => $skopeo::uid,
  }

  group { $skopeo::group:
    ensure => present,
  }

  file { $skopeo::log_dir:
    ensure => directory,
    owner  => $skopeo::user,
  }
}
