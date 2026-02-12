import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'update_service.dart';
import 'aboutpage.dart';
import 'applist.dart';
import 'download_page.dart';
import 'search_page.dart';

import 'home_model.dart';
export 'home_model.dart';

Future<void> _launchPortfolio() async {
  final Uri url = Uri.parse('https://arijeetdas-dev.vercel.app');
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Safe update check - won't crash the app if it fails
      UpdateService.checkForUpdates(context).catchError((e) {
        debugPrint('Failed to check updates: $e');
      });
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF0A0A0F),

        /// AppBar only on small screens (unchanged)
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
                      //Should i place here??
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    Text(
                      'Vibe Labs ⚡',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600,
                            ),
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

        /// ================= BODY =================
        body: Row(
          children: [
            /// -------- LEFT NAV (DESKTOP / TABLET) --------
if (isWideScreen)
  NavigationRail(
    backgroundColor: const Color(0xFF0A0A0F),
    selectedIndex: _selectedIndex,
    onDestinationSelected: (index) {
      setState(() => _selectedIndex = index);


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
                BoxShadow(
                  blurRadius: 16,
                  color: Color(0x558B5CF6),
                )
              ],
            ),
            child: const Icon(
              Icons.bolt,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Vibe Labs ⚡',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w600,
                  ),
                  color: Colors.white,
                ),
          ),
        ],
      ),
    ),

    selectedIconTheme: const IconThemeData(
      color: Color(0xFF8B5CF6),
    ),
    selectedLabelTextStyle: const TextStyle(
      color: Color(0xFF8B5CF6),
      fontWeight: FontWeight.w600,
    ),

    destinations: const [
      NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.apps_outlined),
        selectedIcon: Icon(Icons.apps),
        label: Text('Apps'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.search),
        label: Text('Search'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.download_outlined),
        selectedIcon: Icon(Icons.download),
        label: Text('Downloads'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.info_outline),
        selectedIcon: Icon(Icons.info),
        label: Text('About'),
      ),
    ],
  ),



            /// -------- MAIN CONTENT (UNCHANGED) --------
            Expanded(
            child: Builder(
              builder: (context) {
                switch (_selectedIndex) {
                  case 4:
                    // About tab (DESKTOP ONLY, no back button, navrail stays)
                    return const AboutPage(desktopMode: true);

                  case 1:
                    // Apps tab (DESKTOP)
                    return const AppListPage();
                  case 3:
                    return const DownloadPage();
                  case 2:
                    return const SearchPage();
                  case 0:
                  default:
                    // HOME (your existing content — UNCHANGED)
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// -------- FEATURED APP --------
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF3B82F6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 24,
                                    color: Color(0x558B5CF6),
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x1A000000),
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
                                          Text(
                                            'Featured App',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Calculator',
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'v1.0.1 • Experimental',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  color: Colors.white70,
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          FFButtonWidget(
                                            onPressed: () {},
                                            text: 'Explore Now',
                                            options: FFButtonOptions(
                                              height: 40,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 24),
                                              color: Colors.white,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        color:
                                                            const Color(0xFF0A0A0F),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              elevation: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 84,
                                      height: 84,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 18,
                                            color: Color(0x66000000),
                                          )
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        child: Image.asset(
                                          'assets/icons/calculator.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// -------- EXPERIMENTAL APPS --------
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    'Experimental Apps',
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                _experimentalAppItem(
                                  context,
                                  iconPath: 'assets/icons/dice.png',
                                  name: 'Dice Roller',
                                  version: '1.1.0',
                                ),
                                const SizedBox(height: 12),
                                _experimentalAppItem(
                                  context,
                                  iconPath:
                                      'assets/icons/calculator.png',
                                  name: 'Calculator',
                                  version: '1.0.1',
                                ),
                                const SizedBox(height: 12),
                                _experimentalAppItem(
                                  context,
                                  iconPath: 'assets/icons/meals.png',
                                  name: 'Meal Planner',
                                  version: '1.0.0',
                                ),
                              ],
                            ),
                          ),

                      
                          
                        ]
                            .divide(const SizedBox(height: 24))
                            .addToStart(const SizedBox(height: 16)),
                      ),
                    );
                }
              },
            ),
          ),

          ],
        ),

        /// -------- BOTTOM NAV (MOBILE ONLY) --------
        bottomNavigationBar: isWideScreen
            ? null
            : NavigationBar(
                backgroundColor: const Color(0xFF0A0A0F),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                    

                  
                  setState(() => _selectedIndex = index);
                },
                indicatorColor: const Color(0x338B5CF6),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.apps_outlined),
                    selectedIcon: Icon(Icons.apps),
                    label: 'Apps',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.download_outlined),
                    selectedIcon: Icon(Icons.download),
                    label: 'Downloads',
                  ),
                ],
              ),
      ),
    );
  }

  Widget _techChip(String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: FlutterFlowTheme.of(context).labelSmall.override(
              color: Colors.white,
              fontSize: 10,
            ),
      ),
    );
  }

  Widget _experimentalAppItem(
    BuildContext context, {
    required String iconPath,
    required String name,
    required String version,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1A1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2F),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x1A8B5CF6),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Color(0x4D8B5CF6),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                iconPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: FlutterFlowTheme.of(context)
                      .titleMedium
                      .override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                        ),
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v$version • Experimental',
                  style: FlutterFlowTheme.of(context)
                      .bodySmall
                      .override(
                        color: const Color(0xFF9CA3AF),
                      ),
                ),
              ],
            ),
          ),
          FFButtonWidget(
            onPressed: () {},
            text: 'Install',
            options: FFButtonOptions(
              height: 36,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFF8B5CF6),
              textStyle:
                  FlutterFlowTheme.of(context)
                      .labelMedium
                      .override(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
              borderRadius:
                  BorderRadius.circular(20),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
