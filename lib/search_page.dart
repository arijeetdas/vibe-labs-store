import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_catalog_model.dart';
import '../services/app_catalog_service.dart';
import 'apps_details.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  List<AppEntry> _allApps = [];
  List<AppEntry> _results = [];
  List<String> _recentSearches = [];

  static const int _maxRecent = 8;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final apps = await AppCatalogService.fetchCatalog();
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _allApps = apps;
      _recentSearches =
          prefs.getStringList('recent_searches') ?? <String>[];
    });
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() {
      _results = _allApps.where((app) {
        return app.name.toLowerCase().contains(q) ||
            app.description.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _commitSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    _recentSearches.remove(q);
    _recentSearches.insert(0, q);

    if (_recentSearches.length > _maxRecent) {
      _recentSearches = _recentSearches.take(_maxRecent).toList();
    }

    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _openApp(AppEntry app) async {
    await _commitSearch(app.name);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppDetailsPage(appId: app.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= SEARCH BAR =================
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  onSubmitted: _commitSearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search apps',
                    hintStyle:
                        const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0x1A1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide:
                          const BorderSide(color: Color(0xFF2A2A2F)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide:
                          const BorderSide(color: Color(0xFF2A2A2F)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide:
                          const BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// ================= RECENT =================
            if (_controller.text.isEmpty && _recentSearches.isNotEmpty) ...[
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((q) {
                  return ActionChip(
                    backgroundColor: const Color(0x1A8B5CF6),
                    label: Text(
                      q,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _controller.text = q;
                      _onSearchChanged(q);
                    },
                  );
                }).toList(),
              ),
            ],

            /// ================= RESULTS =================
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Results',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final app = _results[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openApp(app),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x1A1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2A2A2F),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                app.icon,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'v${app.latest.version}',
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
