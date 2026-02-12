import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/download_service.dart';
import '../services/install_state_service.dart';
import '../services/app_metadata_service.dart';
import '../homepage.dart';

class AboutPage extends StatefulWidget {
  final bool desktopMode;
  final bool autoOpenUpdate;
  final bool forcedFromStartup;

  const AboutPage({
    super.key,
    this.desktopMode = false,
    this.autoOpenUpdate = false,
    this.forcedFromStartup = false,
  });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoOpenUpdate) {
        _checkForUpdates(context);
      }
    });
  }

  Future<void> _checkForUpdates(BuildContext context) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        double progress = 0;
        bool checking = true;
        bool downloading = false;
        bool downloaded = false;
        bool updateAvailable = false;
        bool mandatory = false;
        String latestVersion = "";
        String apkUrl = "";
        List<String> changelog = [];

        return StatefulBuilder(
          builder: (context, setState) {

            Future<void> check() async {
              if (!checking) return;

              try {
                final metadata =
                    await AppMetadataService.fetchStoreMetadata();

                latestVersion = metadata.version;
                apkUrl = metadata.apkUrl;
                mandatory = metadata.mandatory;
                changelog = metadata.changelog;

                final installedBuild =
                    await InstallStateService.getInstalledBuild(
                        "com.arijeet.vibelabs.store");

                updateAvailable =
                    installedBuild < metadata.buildNumber;

              } catch (_) {}

              checking = false;
              setState(() {});
            }

            if (checking) {
              check();
            }

            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  checking
                      ? "Checking for updates..."
                      : updateAvailable
                          ? "Update Available"
                          : "No Updates Available",
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                content: checking
                    ? const SizedBox(
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : updateAvailable
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Version $latestVersion is available.",
                                style: const TextStyle(
                                    color: Color(0xFFD1D5DB)),
                              ),
                              const SizedBox(height: 12),
                              ...changelog.map(
                                (e) => Text(
                                  "• $e",
                                  style: const TextStyle(
                                      color: Colors.white70),
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (downloading)
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Downloading (${(progress * 100).toInt()}%)",
                                      style: const TextStyle(
                                          color:
                                              Colors.white70),
                                    ),
                                  ],
                                ),

                              if (downloaded)
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      "Downloaded Successfully",
                                      style: TextStyle(
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                            ],
                          )
                        : const Text(
                            "You are already on the latest version.",
                            style: TextStyle(
                                color: Color(0xFFD1D5DB)),
                          ),
                actions: [

                  if (!checking &&
                      updateAvailable &&
                      !downloading &&
                      !downloaded)
                    TextButton(
                      onPressed: () async {

                        setState(() {
                          downloading = true;
                          progress = 0;
                        });

                        try {
                          await DownloadService.downloadApk(
                            apkUrl,
                            "store_update",
                            onProgress: (p) {
                              setState(() {
                                progress = p;
                              });
                            },
                          );

                          setState(() {
                            downloading = false;
                            downloaded = true;
                          });

                          await Future.delayed(
                              const Duration(seconds: 1));

                          await DownloadService.openInstaller();

                        } catch (_) {
                          setState(() {
                            downloading = false;
                          });
                        }
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(
                            color: Color(0xFF8B5CF6)),
                      ),
                    ),

                  if (!mandatory && !downloading)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);

                        if (widget.autoOpenUpdate) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeWidget(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Later",
                        style: TextStyle(
                            color: Color(0xFF8B5CF6)),
                      ),
                    ),

                  if (mandatory && !downloading)
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: const Text(
                        "Exit",
                        style: TextStyle(
                            color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        title: Text(
          'About',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E1065),
                    Color(0xFF4C1D95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Vibe Labs',
                    style: GoogleFonts.interTight(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vibe Labs is a personal experimentation space where ideas are shipped fast, UI patterns are explored, and small apps are built to learn by doing.\n\nThis app store is a living lab — not a finished product.',
                    style: TextStyle(
                      color: Color(0xFFD1D5DB),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0x1A1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arijeet Das',
                    style: GoogleFonts.interTight(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'FLUTTER • ANDROID • IOS • WEB',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'I am a Flutter-focused developer who builds real products — not just demos.\n\n'
                    'I experiment rapidly, refine UI deeply, and prioritize shipping working software over chasing perfection.\n\n'
                    'Vibe Labs is my execution lab — where ideas turn into usable apps and every release represents growth, iteration, and practical engineering.',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            InkWell(
              onTap: () async {
                final uri =
                    Uri.parse('https://arijeetdas-dev.vercel.app');
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF22C55E),
                      Color(0xFF16A34A),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline,
                        color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'View Portfolio',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            InkWell(
              onTap: () => _checkForUpdates(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF3B82F6),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.system_update,
                        color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Check for updates',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
