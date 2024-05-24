# @summary Manage common configuration
# @api private
class skopeo::config {
  if $skopeo::manage_user {
    user { $skopeo::user:
      ensure     => present,
      managehome => true,
      shell      => '/bin/bash',
      uid        => $skopeo::uid,
    }
  }

  if $skopeo::manage_group {
    group { $skopeo::group:
      ensure => present,
    }
  }

  file { $skopeo::log_dir:
    ensure => directory,
    owner  => $skopeo::user,
  }
}
