class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String home = 'home';
  static const String search = 'search';
  static const String bookmark = 'bookmark';
  static const String notification = 'notification';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String jobDetail = 'jobDetail';
}

class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String search = '/search';
  static const String bookmark = '/bookmark';
  static const String notification = '/notification';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String jobDetail = '/job/:id';

  static String jobDetailPath(int id) => '/job/$id';
}
