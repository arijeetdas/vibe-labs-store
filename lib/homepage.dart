import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

import 'update_service.dart';
import 'aboutpage.dart';
import 'applist.dart';
import 'download_page.dart';
import 'search_page.dart';

import 'services/app_catalog_service.dart';
import 'models/app_catalog_model.dart';
import 'apps_details.dart';

import 'home_model.dart';
export 'home_model.dart';

Future<void> _launchPortfolio() async {
  final Uri url = Uri.parse('https://arijeetdas-dev.vercel.app');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late HomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<AppEntry> _apps = [];
  AppEntry? _featured;
  List<AppEntry> _top3 = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdates(context).catchError((e) {
        debugPrint('Failed to check updates: $e');
      });
    });

    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final apps = await AppCatalogService.getAllApps();

      if (apps.isEmpty) return;

      apps.shuffle(Random());

      setState(() {
        _apps = apps;
        _featured = apps.first;
        _top3 = apps.take(3).toList();
      });
    } catch (e) {
      debugPrint("App load failed: $e");
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _openApp(AppEntry app) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppDetailsPage(appId: app.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF0A0A0F),

        /// APPBAR
        appBar: isWideScreen
            ? null
            : AppBar(
                backgroundColor: const Color(0xFF0A0A0F),
                automaticallyImplyLeading: false,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12,
                            color: Color(0x558B5CF6),
                          )
                        ],
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                    ),
                    Text(
                      'Vibe Labs ⚡',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                            color: Colors.white,
                          ),
                    ),
                  ].divide(const SizedBox(width: 12)),
                ),
                actions: [
                  IconButton(
                    tooltip: 'About',
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      if (!isWideScreen) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AboutPage()),
                        );
                      }
                    },
                  ),
                ],
              ),

        /// BODY
        body: Row(
          children: [
            if (isWideScreen)
              NavigationRail(
                backgroundColor: const Color(0xFF0A0A0F),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                extended: true,
                minExtendedWidth: 220,
                labelType: NavigationRailLabelType.none,
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(blurRadius: 16, color: Color(0x558B5CF6))
                          ],
                        ),
                        child: const Icon(Icons.bolt, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Vibe Labs ⚡',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: Text('Apps')),
                  NavigationRailDestination(icon: Icon(Icons.search), label: Text('Search')),
                  NavigationRailDestination(icon: Icon(Icons.download_outlined), selectedIcon: Icon(Icons.download), label: Text('Downloads')),
                  NavigationRailDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: Text('About')),
                ],
              ),

            /// MAIN
            Expanded(
              child: Builder(
                builder: (context) {
                  switch (_selectedIndex) {
                    case 4:
                      return const AboutPage(desktopMode: true);
                    case 1:
                      return const AppListPage();
                    case 3:
                      return const DownloadPage();
                    case 2:
                      return const SearchPage();

                    case 0:
                    default:
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// FEATURED
                            if (_featured == null)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text('Featured App', style: TextStyle(color: Colors.white70)),
                                            const SizedBox(height: 6),
                                            Text(_featured!.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 6),
                                            Text('v${_featured!.latest.version}', style: const TextStyle(color: Colors.white70)),
                                            const SizedBox(height: 16),
                                            FFButtonWidget(
                                              onPressed: () => _openApp(_featured!),
                                              text: 'Explore Now',
                                              options: FFButtonOptions(
                                                height: 40,
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                                color: Colors.white,
                                                textStyle: const TextStyle(color: Color(0xFF0A0A0F), fontWeight: FontWeight.w600),
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Image.network(_featured!.icon, width: 84, height: 84, fit: BoxFit.cover),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            /// TOP 3
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  Text("Top 3 Apps", style: GoogleFonts.interTight(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                                  const SizedBox(height: 16),

                                  if (_top3.isEmpty)
                                    const Center(child: CircularProgressIndicator())
                                  else
                                    ..._top3.map((app) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: _appItem(app),
                                        )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),

        /// MOBILE NAVBAR
        bottomNavigationBar: isWideScreen
            ? null
            : NavigationBar(
                backgroundColor: const Color(0xFF0A0A0F),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: 'Apps'),
                  NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                  NavigationDestination(icon: Icon(Icons.download_outlined), selectedIcon: Icon(Icons.download), label: 'Downloads'),
                ],
              ),
      ),
    );
  }

  Widget _appItem(AppEntry app) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1A1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2F)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(app.icon, width: 56, height: 56, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(app.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("v${app.latest.version}", style: const TextStyle(color: Color(0xFF9CA3AF))),
            ]),
          ),
          FFButtonWidget(
            onPressed: () => _openApp(app),
            text: 'View',
            options: FFButtonOptions(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFF8B5CF6),
              textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
