import 'package:permission_handler/permission_handler.dart';

//For asking the permission for camera
Future<bool> askCameraPermission() async {
  try {
    final PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  } catch (_) {
    return false;
  }
}

//For asking the permission for gallery
Future<bool> askStoragePermission() async {
  try {
    final PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  } catch (_) {
    return false;
  }
}
