# @summary skopeo image synchronization
# @param user
#   User account used for command execution
# @param group
# @param manage_package
#   Whether package should be installed by this module
# @param manage_user
#   Whether user should be managed by this module
# @param manage_group
#   Whether group should be managed by this module
# @param package_ensure
#   `present`, `absent` or specific package version
# @param uid
#   user id
# @param base_dir
#   Work dir (home dir) for scopeo configs
# @param log_dir
#   Directory for storing logs
# @param sync
#   Synchronization config, see examples
# @param args
#   Optional arguments as Hash
class skopeo (
  String                     $user,
  String                     $group,
  Boolean                    $manage_package,
  Boolean                    $manage_user,
  Boolean                    $manage_group,
  String                     $package_ensure,
  Stdlib::Unixpath           $log_dir,
  Stdlib::Unixpath           $base_dir,
  Skopeo::SyncType           $sync = {},
  Skopeo::Args               $args = {},
  Optional[Integer]          $uid = undef,
) {
  contain skopeo::install
  contain skopeo::config

  create_resources(skopeo::sync, $sync)
}
