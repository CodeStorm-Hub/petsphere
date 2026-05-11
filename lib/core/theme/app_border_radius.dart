import 'package:flutter/material.dart';

class AppBorderRadius {
  const AppBorderRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double pill = 999.0;

  // Semantic Radius
  static const double card = lg;
  static const double button = md;
  static const double input = md;
  static const double image = lg;

  static const BorderRadius circularXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius circularSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius circularMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius circularLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius circularXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius circularXxl = BorderRadius.all(
    Radius.circular(xxl),
  );
  static const BorderRadius circularPill = BorderRadius.all(
    Radius.circular(pill),
  );

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );
}
