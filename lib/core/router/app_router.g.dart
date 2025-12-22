// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$memoListRoute, $onboardingRoute];

RouteBase get $memoListRoute => GoRouteData.$route(
  path: '/',

  factory: _$MemoListRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'settings', factory: _$SettingsRoute._fromState),
    GoRouteData.$route(path: 'new', factory: _$NewMemoRoute._fromState),
  ],
);

mixin _$MemoListRoute on GoRouteData {
  static MemoListRoute _fromState(GoRouterState state) => const MemoListRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$NewMemoRoute on GoRouteData {
  static NewMemoRoute _fromState(GoRouterState state) =>
      NewMemoRoute($extra: state.extra as Memo?);

  NewMemoRoute get _self => this as NewMemoRoute;

  @override
  String get location => GoRouteData.$location('/new');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $onboardingRoute => GoRouteData.$route(
  path: '/onboarding',

  factory: _$OnboardingRoute._fromState,
);

mixin _$OnboardingRoute on GoRouteData {
  static OnboardingRoute _fromState(GoRouterState state) => OnboardingRoute(
    fromSettings:
        _$convertMapValue(
          'from-settings',
          state.uri.queryParameters,
          _$boolConverter,
        ) ??
        false,
  );

  OnboardingRoute get _self => this as OnboardingRoute;

  @override
  String get location => GoRouteData.$location(
    '/onboarding',
    queryParams: {
      if (_self.fromSettings != false)
        'from-settings': _self.fromSettings.toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}
