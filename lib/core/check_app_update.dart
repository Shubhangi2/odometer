// import 'package:in_app_update/in_app_update.dart';

// Future<void> checkForUpdate() async {
//   try {
//     final updateInfo = await InAppUpdate.checkForUpdate();

//     if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//       if (updateInfo.immediateUpdateAllowed) {
//         await InAppUpdate.performImmediateUpdate();
//       } else if (updateInfo.flexibleUpdateAllowed) {
//         await InAppUpdate.startFlexibleUpdate().then((_) {
//           InAppUpdate.completeFlexibleUpdate();
//         });
//       } else {
//         print('No update available');
//       }
//     }
//   } catch (e) {
//     print('Update check failed: $e');
//   }
// }
