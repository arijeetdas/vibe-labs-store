import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../platform/app_launcher.dart';
import '../services/install_state_service.dart';
import '../models/app_catalog_model.dart';
import '../services/app_catalog_service.dart';
import '../services/download_service.dart';

enum InstallState {
  idle,
  downloading,
  downloaded,
  installing,
  installed,
  updateAvailable,
}

class AppDetailsPage extends StatefulWidget {
  final String appId;

  const AppDetailsPage({super.key, required this.appId});

  @override
  State<AppDetailsPage> createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage>
    with SingleTickerProviderStateMixin {
  InstallState _state = InstallState.idle;

  late AnimationController _iconController;
  late Animation<double> _iconScale;

  double _downloadProgress = 0.0;
  bool _isCancelling = false;

  AppEntry? _app;
  Timer? _pollTimer;

  static const double _primaryH = 46;
  static const double _secondaryH = 40;
  static const double _maxButtonWidth = 260;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _iconScale = Tween<double>(begin: 1.0, end: 0.78).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOut),
    );

    _loadApp();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadApp() async {
    final app = await AppCatalogService.getAppById(widget.appId);
    if (!mounted) return;
    setState(() => _app = app);
    await _syncInstallState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => _syncInstallState());
  }

  Future<void> _syncInstallState() async {
    if (_app == null) return;

    final installed =
        await InstallStateService.isInstalled(_app!.packageName);

    if (!mounted) return;

    if (!installed) {
      if (_state != InstallState.downloading &&
          _state != InstallState.installing &&
          _state != InstallState.downloaded) {
        setState(() => _state = InstallState.idle);
      }
      return;
    }

    final installedBuild =
        await InstallStateService.getInstalledBuild(_app!.packageName);

    if (!mounted) return;

    if (installedBuild < _app!.latest.buildNumber) {
      setState(() => _state = InstallState.updateAvailable);
    } else {
      setState(() => _state = InstallState.installed);
    }
  }

  Future<void> _waitForInstallChange(bool expectInstalled) async {
    for (int i = 0; i < 40; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      final installed =
          await InstallStateService.isInstalled(_app!.packageName);

      if (installed == expectInstalled) {
        if (!mounted) return;
        setState(() {
          _state =
              expectInstalled ? InstallState.installed : InstallState.idle;
        });
        return;
      }
    }
  }

  Future<void> _onPrimaryAction() async {
    if (_app == null) return;

    if (_state == InstallState.idle ||
        _state == InstallState.updateAvailable) {
      setState(() {
        _state = InstallState.downloading;
        _downloadProgress = 0;
        _isCancelling = false;
      });

      _iconController.forward();

      try {
        await DownloadService.downloadApk(
          _app!.latest.apkUrl,
          _app!.id,
          onProgress: (p) {
            if (!mounted || _isCancelling) return;
            setState(() => _downloadProgress = p);
          },
        );
      } catch (_) {
        if (!mounted) return;

        final installed =
            await InstallStateService.isInstalled(_app!.packageName);

        setState(() {
          _downloadProgress = 0;
          _state =
              installed ? InstallState.updateAvailable : InstallState.idle;
        });
        return;
      }

      if (!mounted || _isCancelling) return;

      setState(() {
        _state = InstallState.downloaded;
        _downloadProgress = 1.0;
      });

      return;
    }

    if (_state == InstallState.downloaded) {
      setState(() => _state = InstallState.installing);

      await DownloadService.openInstaller();

      await _waitForInstallChange(true);
      return;
    }

    if (_state == InstallState.installed) {
      await AppLauncher.openApp(_app!.packageName);
    }
  }

  Future<void> _cancelDownload() async {
    _isCancelling = true;
    await DownloadService.cancelDownload();

    if (!mounted) return;

    final installed =
        await InstallStateService.isInstalled(_app!.packageName);

    setState(() {
      _downloadProgress = 0;
      _state =
          installed ? InstallState.updateAvailable : InstallState.idle;
    });
  }

  Future<void> _onUninstall() async {
    await AppLauncher.uninstallApp(_app!.packageName);
    await _waitForInstallChange(false);
  }

  String get _primaryText {
    if (_state == InstallState.downloading) {
      return 'Downloading… ${(_downloadProgress * 100).toInt()}%';
    }
    if (_state == InstallState.downloaded) return 'Install';
    if (_state == InstallState.installing) return 'Installing...';
    if (_state == InstallState.installed) return 'Open';
    if (_state == InstallState.updateAvailable) return 'Update';
    return 'Download';
  }

  Color get _primaryColor {
    if (_state == InstallState.updateAvailable) return Colors.green;
    return const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    if (_app == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final app = _app!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        title: Text(app.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition(
                      scale: _iconScale,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          app.icon,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_state == InstallState.downloading)
                      CircularPercentIndicator(
                        radius: 52,
                        percent: _downloadProgress,
                        lineWidth: 4,
                        progressColor: Colors.blueAccent,
                        backgroundColor: Colors.white24,
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        'Arijeet Das • v${app.latest.version}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: _maxButtonWidth),
                          child: SizedBox(
                            width: double.infinity,
                            height: _primaryH,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                              ),
                              onPressed: _onPrimaryAction,
                              child: Text(_primaryText),
                            ),
                          ),
                        ),
                      ),
                      if (_state == InstallState.downloading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: _maxButtonWidth),
                              child: SizedBox(
                                width: double.infinity,
                                height: _secondaryH,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.close,
                                      color: Colors.redAccent),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(
                                        color: Colors.redAccent),
                                  ),
                                  onPressed: _cancelDownload,
                                  label: const Text('Cancel'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_state == InstallState.installed ||
                          _state == InstallState.updateAvailable)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: _maxButtonWidth),
                              child: SizedBox(
                                width: double.infinity,
                                height: _secondaryH,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(
                                        color: Colors.redAccent),
                                  ),
                                  onPressed: _onUninstall,
                                  label: const Text('Uninstall'),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _section('What’s New'),
            ...app.changelog.map(
              (e) => Text('• $e',
                  style: const TextStyle(color: Colors.white70)),
            ),

            const SizedBox(height: 32),
            _section('Screenshots'),
            SizedBox(
              height: 460,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: app.screenshots.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 16),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () =>
                      _openGallery(context, app.screenshots, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(app.screenshots[i],
                        width: 260, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            _section('About this app'),
            Text(app.description,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      );

  void _openGallery(
      BuildContext context, List<String> images, int start) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: start),
                  itemCount: images.length,
                  itemBuilder: (_, i) => InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image.network(images[i],
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                            BorderRadius.circular(20)),
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
