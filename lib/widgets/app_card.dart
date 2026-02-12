import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_model.dart';

class AppCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback? onAction;

  const AppCard({
    super.key,
    required this.app,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1A1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2F)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x1A8B5CF6),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
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
                  style: GoogleFonts.interTight(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.isComingSoon
                      ? 'Coming Soon'
                      : 'v${app.version} • ${app.status}',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: app.isComingSoon ? null : onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              app.isComingSoon ? 'Soon' : 'Install',
            ),
          ),
        ],
      ),
    );
  }
}
