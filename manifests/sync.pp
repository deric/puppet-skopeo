# @summary Manage configuration for scopeo sync
#
# Sync copies Docker/OCI images from source to destination registry
# @param src
#   Source registry
# @param dest
#   Destination registry
# @param matrix
#   A hash with `images` and `versions` array that will be cross joined
# @param tls_verify
#   HTTPS TLS verification
#
# @example
#   skopeo::sync { 'registry':
#     src  => 'index.docker.io',
#     dest => 'my.registry',
#   }
define skopeo::sync (
  String $src,
  String $dest,
  Optional[Skopeo::Matrix] $matrix = undef,
  Hash[String, String] $by_tag = {},
  Boolean $tls_verify = true,
  String $user = $skopeo::user,
  String $group = $skopeo::group,
  Stdlib::Unixpath $base_dir = $skopeo::base_dir,
  Stdlib::Unixpath $log_dir = $skopeo::log_dir,
  Optional[String] $dest_prefix = undef,
) {
  $config = {
    $src => {
      'tls-verify' => $tls_verify,
    },
  }

  if $matrix {
    # cross product (versions x images)
    $_m = $matrix['images'].reduce({}) |$res, $img| {
      merge($res, { $img => $matrix['versions'].map |$val| { $val } })
    }

    $_conf = deep_merge($config, { $src => { 'images' => $_m } })
  } else {
    $_conf = $config
  }

  file { "${base_dir}/${title}.yaml":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => inline_epp('<%= $config.to_yaml %>', {
        config => $_conf,
    }),
    notify  => Exec["skopeo_sync-${title}"],
  }

  $_dest = $dest_prefix ? {
    undef   => $dest,
    default => "${dest}/${dest_prefix}",
  }

  exec { "skopeo_sync-${title}":
    command     => "skopeo sync --src yaml --dest docker ${base_dir}/${title}.yaml ${_dest} >> ${log_dir}/skopeo.log 2>&1",
    environment => "XDG_RUNTIME_DIR=/run/user/${skopeo::uid}",
    path        => $facts['path'],
    user        => $user,
    cwd         => $base_dir,
    provider    => 'shell',
    refreshonly => true,
    require     => [File[$log_dir]],
  }

  # cron { 'sync-k8s':
  #   ensure  => present,
  #   command => "skopeo sync --src yaml --dest docker k8s.yml ${dest}/k8s.io",
  #   user    => $user,
  #   hour    => '*/4', # in 4 hours intervals
  #   minute  => '5',
  #   require => Package['skopeo'],
  # }
}
