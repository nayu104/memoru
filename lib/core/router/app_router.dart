import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/screens/memo_list_screen.dart';
import '../../features/screens/new_memo_modal.dart';
import '../../features/screens/onboarding_screen.dart';
import '../../features/screens/setting_screen.dart';
import '../domain/memo.dart';
import '../provider/app_info_provider.dart';

part 'app_router.g.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final isFirstLaunch = ref.watch(isFirstLaunchProvider);
  return GoRouter(
    initialLocation: isFirstLaunch ? '/onboarding' : '/',
    routes: $appRoutes,
  );
});

@TypedGoRoute<MemoListRoute>(
  path: '/',
  routes: [
    TypedGoRoute<SettingsRoute>(path: 'settings'),
    TypedGoRoute<NewMemoRoute>(path: 'new'),
  ],
)
class MemoListRoute extends GoRouteData with _$MemoListRoute {
  const MemoListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MemoListScreen();
}

class SettingsRoute extends GoRouteData with _$SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingScreen();
}

class NewMemoRoute extends GoRouteData with _$NewMemoRoute {
  final Memo? $extra;

  const NewMemoRoute({this.$extra});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage(
        fullscreenDialog: true,
        child: NewMemoModal(initial: $extra),
      );
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with _$OnboardingRoute {
  final bool fromSettings;

  const OnboardingRoute({this.fromSettings = false});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OnboardingScreen(fromSettings: fromSettings);
}
