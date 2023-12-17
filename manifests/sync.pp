# @summary Manage configuration for scopeo sync
#
# Sync copies Docker/OCI images from source to destination registry
# @param src
#   Source registry
# @param src_type
#   Source transport: `docker`,`dir` or `yaml`. Default is `yaml`
# @param dest
#   Destination registry
# @param dest_prefix
#   Set prefix for destination registry
# @param dest_type
#   Destination transport, either `docker` or `dir`. Default: `docker`
# @param args
#   Optional key-value arguments passed to the sync command
# @param matrix
#   A hash with `images` and `versions` array that will be cross joined
# @param by_tag
#  Hash containing image name and version (regexp)
# @param tls_verify
#   HTTPS TLS verification
# @param redirect_logs
#   Whether logs should be redirected to a file stored in the `log_dir`
# @param on_change
#   Whether synchronization should be performed upon config change
# @param user
# @param group
# @param base_dir
# @param log_dir
#
# @example
#   skopeo::sync { 'registry':
#     src  => 'index.docker.io',
#     dest => 'my.registry',
#   }
define skopeo::sync (
  String                   $src,
  String                   $dest,
  Skopeo::SrcType          $src_type = 'yaml',
  Skopeo::DestType         $dest_type = 'docker',
  Skopeo::Args             $args = $skopeo::args,
  Optional[Skopeo::Matrix] $matrix = undef,
  Skopeo::ByTag            $by_tag = {},
  Boolean                  $tls_verify = true,
  Boolean                  $redirect_logs = true,
  Boolean                  $on_change = true,
  String                   $user = $skopeo::user,
  String                   $group = $skopeo::group,
  Stdlib::Unixpath         $base_dir = $skopeo::base_dir,
  Stdlib::Unixpath         $log_dir = $skopeo::log_dir,
  Optional[String]         $dest_prefix = undef,
) {
  $imgs = !empty($matrix) ? {
    # cross product (versions x images)
    true => $matrix['images'].reduce({}) |$res, $img| {
      merge($res, { $img => $matrix['versions'].map |$val| { $val } })
    },
    false => {},
  }

  # soon to be YAML
  $registry = {
    'tls-verify' => $tls_verify,
    'images' => $imgs,
    'images-by-tag-regex' => $by_tag,
  }

  $non_empty = $registry.filter |$keys, $values| { type($values) =~ Type[Boolean] or !empty($values) }

  # final filtered hash
  $config = {
    $src => $non_empty,
  }

  file { "${base_dir}/${title}.yaml":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => inline_epp('<%= $config.to_yaml %>', {
        config => $config,
    }),
  }

  $_dest = $dest_prefix ? {
    undef   => $dest,
    default => "${dest}/${dest_prefix}",
  }

  $_redirect = $redirect_logs ? {
    true => " >> ${log_dir}/skopeo.log 2>&1",
    false => '',
  }

  # optional args
  $_args = join($args.map |$key, $value| {
      if $key.length > 1 {
        if empty($value) {
          " --${key}"
        } else {
          " --${key} ${value}"
        }
      } else {
        " -${key} ${value}" # short args, e.g. -f oci
      }
  },'')

  if $on_change {
    exec { "skopeo_sync-${title}":
      command     => "skopeo sync${_args} --src ${src_type} --dest ${dest_type} ${base_dir}/${title}.yaml ${_dest}${_redirect}",
      environment => "XDG_RUNTIME_DIR=/run/user/${skopeo::uid}",
      path        => $facts['path'],
      user        => $user,
      cwd         => $base_dir,
      provider    => 'shell',
      refreshonly => true,
      require     => [File[$log_dir]],
      subscribe   => File["${base_dir}/${title}.yaml"],
    }
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
