import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle pageTitle = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static TextStyle headingMedium = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headingSmall = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  // Subtitles / Body
  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColorsDark.textSecondary,
    height: 1.4,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Form Field Labels & Hints
  static TextStyle fieldLabel = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle fieldHint = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle inputText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // Buttons
  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static TextStyle textButtonRed = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColorsDark.primaryRed,
  );

  // Table & Badges
  static TextStyle tableHeader = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle tableCell = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle badgeText = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // Brand Logo typography (sidebar anchor)
  static TextStyle logoSLS = GoogleFonts.montserrat(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 1.0,
  );

  static TextStyle logoTitleRed = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryRed,
    letterSpacing: 0.8,
  );

  static TextStyle logoTitleWhite = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.8,
  );

  static TextStyle logoSubtitle = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColorsDark.textSecondary,
    letterSpacing: 2.0,
  );
}
