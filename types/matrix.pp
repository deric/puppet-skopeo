# Configuration images X versions to sync
type Skopeo::Matrix = Struct[{
  images => Array[String[1]],
  versions => Array[String[1]],
}]
