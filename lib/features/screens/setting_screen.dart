import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memomemo/core/constants/app_urls.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/router/app_router.dart';
import '../widgets/setting_ui_components.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logScreenView(screenName: 'SettingScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        leading: IconButton(
          tooltip: '設定画面を閉じるボタン',
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // ── サポート ──────────────────────────────
          const SectionTitle(title: 'サポート'),
          SettingTile(
            icon: Icons.mail_outline,
            title: 'お問い合わせ・ご要望',
            onTap: () async {
              final url = Uri.parse(AppUrls.contactForm);
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                debugPrint('Could not launch $url');
              }
            },
          ),
          const Divider(),

          // ── アプリ情報 ─────────────────────────────
          const SectionTitle(title: 'アプリ情報'),
          SettingTile(
            icon: Icons.help_outline,
            title: '使い方を見る',
            onTap: () {
              const OnboardingRoute(fromSettings: true).push<void>(context);
            },
          ),
          SettingTile(
            icon: Icons.description,
            title: '利用規約',
            onTap: () {
              const TermsOfServiceRoute().push<void>(context);
            },
          ),
          SettingTile(
            icon: Icons.privacy_tip,
            title: 'プライバシーポリシー',
            onTap: () {
              const PrivacyPolicyRoute().push<void>(context);
            },
          ),
          SettingTile(
            icon: Icons.info_outline,
            title: 'バージョン',
            subtitle: '1.0.0',
            showTrailingArrow: false,
            onTap: () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
