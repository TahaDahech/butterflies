import 'package:flutter/material.dart';

class SizingUtil {
  static SizingData getSizingData(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine screen size category
    bool isSmallScreen = screenWidth < 400;
    bool isMediumScreen = screenWidth >= 400 && screenWidth < 800;

    return SizingData(
      welcomeFontSize: isSmallScreen
          ? 18
          : isMediumScreen
              ? 24
              : 32,
      subtitleFontSize: isSmallScreen
          ? 12
          : isMediumScreen
              ? 16
              : 18,
      descriptionFontSize: isSmallScreen
          ? 26
          : isMediumScreen
              ? 38
              : 48,
      paddingVertical: isSmallScreen
          ? 10
          : isMediumScreen
              ? 20
              : 50,
      paddingHorizontal: isSmallScreen
          ? screenWidth / 20
          : isMediumScreen
              ? screenWidth / 15
              : screenWidth / 12,
      paddingRight: isSmallScreen
          ? screenWidth / 10
          : isMediumScreen
              ? screenWidth / 4
              : screenWidth / 2.5,
      logoHeight: isSmallScreen
          ? 50
          : isMediumScreen
              ? 60
              : 70,
      buttonPadding: EdgeInsets.symmetric(
        vertical: isSmallScreen
            ? 8.0
            : isMediumScreen
                ? 12.0
                : 16.0,
        horizontal: isSmallScreen
            ? 16.0
            : isMediumScreen
                ? 20.0
                : 24.0,
      ),
      buttonFontSize: isSmallScreen
          ? 12.0
          : isMediumScreen
              ? 14.0
              : 16.0,
      buttonHeight: isSmallScreen
          ? 40.0
          : isMediumScreen
              ? 48.0
              : 56.0,
      gridCrossAxisCount: isSmallScreen
          ? 2
          : isMediumScreen
              ? 3
              : 4,
      drawerWidth: isSmallScreen
          ? 0
          : isMediumScreen
              ? 200
              : 250,
      isSmallScreen: isSmallScreen,
    );
  }
}

class SizingData {
  final double welcomeFontSize;
  final double subtitleFontSize;
  final double descriptionFontSize;
  final double paddingVertical;
  final double paddingHorizontal;
  final double paddingRight;
  final double logoHeight;
  final EdgeInsets buttonPadding;
  final double buttonFontSize;
  final double buttonHeight;
  final int gridCrossAxisCount;
  final double drawerWidth;
  final bool isSmallScreen;

  SizingData({
    required this.welcomeFontSize,
    required this.subtitleFontSize,
    required this.descriptionFontSize,
    required this.paddingVertical,
    required this.paddingHorizontal,
    required this.paddingRight,
    required this.logoHeight,
    required this.buttonPadding,
    required this.buttonFontSize,
    required this.buttonHeight,
    required this.gridCrossAxisCount,
    required this.drawerWidth,
    required this.isSmallScreen,
  });
}
