import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedScribe_Theme {
  static const Color grey = Color(0XFF979797);
  static const Color secondary_color = Color(0XFFFF9B63);
  static const Color black = Color(0xFF252525);
  static const Color white = Color(0XFFFFFFFF);

  static const Color disable_button_theme = Color(0XFFFF9B63);
  static const Color enable_button_theme = Color(0XFFFF621F);

  static TextStyle home_title = GoogleFonts.inter(
      color: Color(0xFFFF800B), fontSize: 20, fontWeight: FontWeight.w700);
  static TextStyle home_desc = GoogleFonts.inter(
      color: Color(0xFF595959), fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle main_title_text_style = GoogleFonts.inter(
      color: Color(0XFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle main_desc_text_style = GoogleFonts.inter(
      color: Color(0XFFFFFFFF), fontSize: 12, fontWeight: FontWeight.w600);
}
