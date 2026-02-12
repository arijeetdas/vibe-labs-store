import 'package:flutter/material.dart';
import '../services/download_service.dart';

class UpdateDialog extends StatelessWidget {
  final String appName;
  final String version;
  final List<String> changelog;
  final String apkUrl;

  const UpdateDialog({
    super.key,
    required this.appName,
    required this.version,
    required this.changelog,
    required this.apkUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF12121A),
      title: Text(
        '$appName update available',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version $version',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ...changelog.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $e',
                    style: const TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Later'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Update'),
          onPressed: () async {
            Navigator.pop(context);
            await DownloadService.downloadAndInstall(apkUrl);
          },
        ),
      ],
    );
  }
}
