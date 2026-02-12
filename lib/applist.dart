import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_model.dart';
import 'apps_details.dart';

class AppListPage extends StatelessWidget {
  const AppListPage({super.key});

  static const String _iconBase =
      'https://raw.githubusercontent.com/arijeetdas/vibe-labs-appstore/main/icons';

  List<AppModel> _apps() {
    return [
      AppModel(
        id: 'calculator',
        name: 'Calculator',
        icon: '$_iconBase/calculator.png',
        status: 'Experimental',
        version: '1.0.1',
        isLatest: true,
        isComingSoon: false,
      ),
      AppModel(
        id: 'dice',
        name: 'Dice Roller',
        icon: '$_iconBase/dice.png',
        status: 'Experimental',
        version: '1.1.0',
        isLatest: true,
        isComingSoon: false,
      ),
    ];
  }

  AppModel _randomLatest(List<AppModel> apps) {
    return apps[Random().nextInt(apps.length)];
  }

  @override
  Widget build(BuildContext context) {
    final apps = _apps();
    final latest = _randomLatest(apps);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= EXPLORE =================
            const Text(
              'Explore',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 190,
              child: PageView(
                controller: PageController(viewportFraction: 0.88),
                children: [
                  _latestCarouselCard(context, latest),
                  _comingSoonCarouselCard(),
                ],
              ),
            ),

            const SizedBox(height: 36),

            /// ================= ALL APPS =================
            const Text(
              'All Apps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            ...apps.map(
              (app) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _appListItem(context, app),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -----------------------------------------------------

  Widget _latestCarouselCard(BuildContext context, AppModel app) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppDetailsPage(appId: app.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              blurRadius: 28,
              color: Color(0x668B5CF6),
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latest App',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'v${app.version} • ${app.status}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                app.icon,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comingSoonCarouselCard() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 28,
            color: Color(0x5522C55E),
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Meal Planner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Plan smarter meals effortlessly',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              '$_iconBase/meals.png',
              width: 76,
              height: 76,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appListItem(BuildContext context, AppModel app) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppDetailsPage(appId: app.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x1A1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2F)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                app.icon,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v${app.version} • ${app.status}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
