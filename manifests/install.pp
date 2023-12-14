# @summary Manage skopeo binary installation
#
#
# @api private
class skopeo::install {
  if $skopeo::manage_package {
    ensure_packages(['skopeo'], { 'ensure' => $skopeo::package_ensure })
  }
}
