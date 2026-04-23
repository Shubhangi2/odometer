import 'package:speedometer/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class OpenSettingDialog extends StatelessWidget {
  const OpenSettingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.8,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Need Permissions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text(
              "This apps needs permission to use this feature. You can grant them in app settings.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'GO TO SETTINGS',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
