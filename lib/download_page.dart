import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../platform/app_launcher.dart';
import '../services/install_state_service.dart';
//import 'package:android_intent_plus/android_intent.dart';

import '../models/app_catalog_model.dart';
import '../services/app_catalog_service.dart';
import 'apps_details.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  bool _checkingUpdates = false;

  final List<_UpdateEntry> _updates = [];
  List<AppEntry> _installedApps = [];

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
    _checkForUpdates();
  }

  

  Future<void> _loadInstalledApps() async {
  final catalog = await AppCatalogService.fetchCatalog();
  final List<AppEntry> installed = [];

  for (final app in catalog) {
    final isInstalled =
        await InstallStateService.isInstalled(app.packageName);

    if (isInstalled) {
      installed.add(app);
    }
  }

  if (!mounted) return;
  setState(() => _installedApps = installed);
}

  Future<void> _checkForUpdates() async {
  setState(() {
    _checkingUpdates = true;
    _updates.clear();
  });

  final catalog = await AppCatalogService.fetchCatalog();

  for (final app in catalog) {
    final isInstalled =
        await InstallStateService.isInstalled(app.packageName);

    if (!isInstalled) continue;

    final installedBuild =
        await InstallStateService.getInstalledBuild(
            app.packageName);

    if (installedBuild < app.latest.buildNumber) {
      _updates.add(
        _UpdateEntry(
          app: app,
          oldVersion: 'Installed',
          newVersion: app.latest.version,
        ),
      );
    }
  }

  if (!mounted) return;
  setState(() => _checkingUpdates = false);
}

  Future<void> _openApp(String packageName) async {
    await AppLauncher.openApp(packageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= UPDATES =================
            Row(
              children: [
                const Text(
                  'Check for Updates',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: _checkingUpdates
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  color: Colors.white70,
                  onPressed:
                      _checkingUpdates ? null : _checkForUpdates,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0x1A1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0xFF2A2A2F)),
              ),
              child: _updates.isEmpty
                  ? Center(
                      child: Text(
                        _checkingUpdates
                            ? 'Checking for updates…'
                            : 'All apps are up-to-date',
                        style:
                            const TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _updates.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final u = _updates[i];

                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(12),
                              child: Image.network(
                                u.app.icon,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u.app.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${u.oldVersion} → ${u.newVersion}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AppDetailsPage(
                                      appId: u.app.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            const SizedBox(height: 32),

            /// ================= INSTALLED =================
            const Text(
              'Installed Apps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            ..._installedApps.map(
              (app) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x1A1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFF2A2A2F)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Image.network(
                          app.icon,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.latest.version,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _openApp(app.packageName),
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateEntry {
  final AppEntry app;
  final String oldVersion;
  final String newVersion;

  _UpdateEntry({
    required this.app,
    required this.oldVersion,
    required this.newVersion,
  });
}
