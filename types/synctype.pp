# Configuration of synchronization targets
type Skopeo::SyncType = Hash[
  String, Struct[{
    src         => String,
    dest        => String,
    Optional[dest_prefix] => String,
  }]
]
