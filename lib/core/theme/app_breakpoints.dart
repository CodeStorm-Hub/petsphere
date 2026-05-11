class AppBreakpoints {
  const AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  static const double mobile = compact;
  static const double tablet = medium;
  static const double desktop = expanded;
  static const double wide = 1440;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < medium;
  static bool isExpanded(double width) => width >= medium;
  static bool isMobile(double width) => isCompact(width);
  static bool isTablet(double width) => isMedium(width);
  static bool isDesktop(double width) => width >= expanded;
}
