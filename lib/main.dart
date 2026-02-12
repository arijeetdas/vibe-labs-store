import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibe_labs/homepage.dart';
import 'package:vibe_labs/aboutpage.dart';

import 'services/app_metadata_service.dart';
import 'services/install_state_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VibeLabsApp());
}

class VibeLabsApp extends StatelessWidget {
  const VibeLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vibe Labs ⚡',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF8B5CF6),
      ),
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForStoreUpdate();
    });
  }

  Future<void> _checkForStoreUpdate() async {
    try {
      final metadata =
          await AppMetadataService.fetchStoreMetadata();

      final installedBuild =
          await InstallStateService.getInstalledBuild(
              "com.arijeet.vibelabs.store");

      final bool updateAvailable =
          installedBuild < metadata.buildNumber;

      final bool mandatoryUpdate =
          metadata.mandatory && updateAvailable;

      if (!mounted) return;

      if (mandatoryUpdate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mandatory update available"),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 600));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AboutPage(
              autoOpenUpdate: true,
              forcedFromStartup: true,
            ),
          ),
        );
        return;
      }

      if (updateAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Update available"),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 600));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AboutPage(
              autoOpenUpdate: true,
              forcedFromStartup: false,
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeWidget(),
        ),
      );

    } catch (_) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeWidget(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0F),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
