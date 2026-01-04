import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:memomemo/core/constants/app_urls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memomemo/core/provider/memo_state.dart';
import 'package:memomemo/crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../core/router/app_router.dart';
import '../widgets/setting_ui_components.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});
  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
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
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // ── データ設定 ─────────────────────────────
          const SectionTitle(title: 'データ / メモル星へ送られます'),
          SettingTile(
            icon: Icons.backup,
            title: 'バックアップ / 復元',
            onTap: () => _handleBackup(context, ref),
          ),
          SettingTile(
            icon: Icons.delete_forever,
            title: 'すべてのメモを削除',
            titleColor: Theme.of(context).colorScheme.error,
            onTap: () => _handleDeleteAll(context, ref),
          ),
          const Divider(),

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
          SettingTile(icon: Icons.star_rate, title: 'レビューを書く', onTap: () {}),
          const Divider(),

          // ── アプリ情報 ─────────────────────────────
          const SectionTitle(title: 'アプリ情報'),
          SettingTile(
            icon: Icons.help_outline,
            title: '使い方を見る',
            onTap: () {
              const OnboardingRoute(fromSettings: true).push(context);
            },
          ),
          SettingTile(icon: Icons.description, title: '利用規約', onTap: () {}),
          SettingTile(
            icon: Icons.privacy_tip,
            title: 'プライバシーポリシー',
            onTap: () {},
          ),
          SettingTile(
            icon: Icons.info_outline,
            title: 'バージョン',
            subtitle: '1.0.0',
            onTap: () {},
          ),
          const Divider(),
          SettingTile(
            icon: Icons.bug_report,
            title: 'クラッシュテスト',
            titleColor: Theme.of(context).colorScheme.error,
            onTap: () {
              Crashlytics.log('ログ');
              Crashlytics.crash('アプリクラッシュテスト');
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('クラウドに保存しています...')));
    try {
      await ref.read(memoNotifierProvider.notifier).backupToCloud();
      if (context.mounted) {
        // 前のスナックバーを消してから新しいのを出す
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存しました！')));
      }
    } catch (e) {
      // 4. 失敗フィードバック
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAll(BuildContext context, WidgetRef ref) async {
    // 1. ダイアログを表示し、ユーザーの決断を待つ (await)
    // 削除なら true, キャンセルなら false (または null) が返ってくる
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('すべてのメモを削除'),
        content: const Text('本当にすべてのメモを削除しますか？\nこの操作は元に戻せません。'),
        actions: [
          TextButton(
            // キャンセルなら false を返して閉じる
            onPressed: () => context.pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            // 削除なら true を返して閉じる
            onPressed: () => context.pop(true),
            child: Text(
              '削除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    // 2. ダイアログが閉じた後の処理
    // ユーザーが「削除」を選んだ場合のみ実行
    if (shouldDelete == true) {
      await ref.read(memoNotifierProvider.notifier).deleteAll();

      // 3. フィードバックを表示 (SnackBar)
      // 非同期処理の後なので、設定画面であるか確認(mounted)してから表示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('すべてのメモを削除しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
