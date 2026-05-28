/// Result of a permission request.
enum PermissionStatus {
  /// The user granted access to the media library.
  granted,

  /// The user denied the permission (can ask again).
  denied,

  /// The user permanently denied the permission (cannot ask again).
  deniedForever,
}
