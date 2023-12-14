# Configuration of synchronization targets
type Skopeo::SyncType = Hash[
  String[1], Struct[{
    src         => String[1],
    dest        => String[1],
    Optional[dest_prefix] => String[1],
  }]
]
