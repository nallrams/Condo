import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Custom font helper that avoids the Google Fonts AssetManifest conflict
class FontLoader {
  /// Loads a custom font and applies it to the theme
  static ThemeData withCustomFont(ThemeData theme, String fontFamily) {
    return theme.copyWith(
      textTheme: theme.textTheme.apply(
        fontFamily: fontFamily,
      ),
      primaryTextTheme: theme.primaryTextTheme.apply(
        fontFamily: fontFamily,
      ),
    );
  }
}