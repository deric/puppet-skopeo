# Configuration of synchronization targets
type Skopeo::SyncType = Hash[
  String[1], Struct[{
    src                   => String[1],
    dest                  => String[1],
    Optional[dest_prefix] => String[1],
    Optional[matrix]      => Skopeo::Matrix,
    Optional[by_tag]      => Skopeo::ByTag,
    Optional[tls_verify]  => Boolean,
    Optional[user]        => String,
    Optional[group]       => String,
    Optional[base_dir]    => Stdlib::Unixpath,
    Optional[log_dir]     => Stdlib::Unixpath,
  }]
]
