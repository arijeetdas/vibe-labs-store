import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) => FlutterFlowTheme();

  Color get primary => const Color(0xFF8B5CF6);
  Color get secondary => const Color(0xFF3B82F6);
  Color get tertiary => const Color(0xFF10B981);
  Color get primaryBackground => const Color(0xFF0A0A0F);

  TextStyle get titleLarge => GoogleFonts.interTight(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  TextStyle get titleMedium => GoogleFonts.interTight(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white70,
      );

  TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white54,
      );

  TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        color: Colors.white70,
      );
}
