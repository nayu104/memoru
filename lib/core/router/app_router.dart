import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/screens/memo_list_screen.dart';
import '../../features/screens/memoru_star_screen.dart';
import '../../features/screens/new_memo_modal.dart';
import '../../features/screens/onboarding_screen.dart';
import '../../features/screens/privacy_policy_page.dart';
import '../../features/screens/setting_screen.dart';
import '../../features/screens/terms_of_service_page.dart';
import '../application/app_info_provider.dart';
import '../domain/memo.dart';

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
    TypedGoRoute<SettingsRoute>(
      path: 'settings',
      routes: [
        TypedGoRoute<TermsOfServiceRoute>(path: 'terms'),
        TypedGoRoute<PrivacyPolicyRoute>(path: 'privacy'),
      ],
    ),
    TypedGoRoute<NewMemoRoute>(path: 'new'),
    TypedGoRoute<MemoruStarRoute>(path: 'star'),
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

class TermsOfServiceRoute extends GoRouteData with _$TermsOfServiceRoute {
  const TermsOfServiceRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TermsOfServicePage();
}

class PrivacyPolicyRoute extends GoRouteData with _$PrivacyPolicyRoute {
  const PrivacyPolicyRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PrivacyPolicyPage();
}

class NewMemoRoute extends GoRouteData with _$NewMemoRoute {
  const NewMemoRoute({this.$extra});

  final Memo? $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage(
        fullscreenDialog: true,
        child: NewMemoModal(initial: $extra),
      );
}

class MemoruStarRoute extends GoRouteData with _$MemoruStarRoute {
  const MemoruStarRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MemoruStarScreen();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with _$OnboardingRoute {
  const OnboardingRoute({this.fromSettings = false});

  final bool fromSettings;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OnboardingScreen(fromSettings: fromSettings);
}
