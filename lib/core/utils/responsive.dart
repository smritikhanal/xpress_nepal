import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 650;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 650 &&
        MediaQuery.of(context).size.width < 1100;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1100;
  }

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double fontSize(BuildContext context, double size) {
    if (isTablet(context)) {
      return size * 1.2;
    } else if (isDesktop(context)) {
      return size * 1.4;
    }
    return size;
  }

  static double spacing(BuildContext context, double space) {
    if (isTablet(context)) {
      return space * 1.5;
    } else if (isDesktop(context)) {
      return space * 2;
    }
    return space;
  }

  static EdgeInsets padding(BuildContext context, EdgeInsets basePadding) {
    if (isTablet(context)) {
      return basePadding * 1.5;
    } else if (isDesktop(context)) {
      return basePadding * 2;
    }
    return basePadding;
  }

  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return width(context);
    } else if (isTablet(context)) {
      return 700;
    }
    return 600;
  }
}
