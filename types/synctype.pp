# Configuration of synchronization targets
type Skopeo::SyncType = Hash[
  String[1], Struct[{
    src                     => String[1],
    dest                    => String[1],
    Optional[dest_prefix]   => String[1],
    Optional[src_type]      => Skopeo::SrcType,
    Optional[dest_type]     => Skopeo::DestType,
    Optional[matrix]        => Skopeo::Matrix,
    Optional[by_tag]        => Skopeo::ByTag,
    Optional[tls_verify]    => Boolean,
    Optional[redirect_logs] => Boolean,
    Optional[user]          => String,
    Optional[group]         => String,
    Optional[base_dir]      => Stdlib::Unixpath,
    Optional[log_dir]       => Stdlib::Unixpath,
  }]
]
