import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memomemo/gen/assets.gen.dart';
import '../../core/router/app_router.dart';
import '../../core/provider/memo_state.dart';
import '../../core/provider/search_state.dart';
import '../../core/widgets/skeleton_container.dart';
import '../widgets/memo_card.dart';

class MemoListScreen extends ConsumerStatefulWidget {
  const MemoListScreen({super.key});
  @override
  ConsumerState<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends ConsumerState<MemoListScreen> {
  late final TextEditingController _searchController;

  bool _isFabPressed = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Riverpodの状態監視 (AsyncValue<List<Memo>>)
    final asyncMemos = ref.watch(memoNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('気分でメモル'),
        actions: [
          IconButton(
            tooltip: '設定画面を開くボタン',
            onPressed: () {
              const SettingsRoute().go(context);
            },
            icon: const Icon(Icons.settings), // 色指定を削除（テーマに従う）
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.black38),
                hintText: 'けんさく',
                hintStyle: const TextStyle(color: Colors.black38),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          const SizedBox(height: 12),

          // コンテンツエリア
          Expanded(
            child: Stack(
              children: [
                // 背景画像
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: Assets.images.memomemo.image(),
                  ),
                ),

                // Riverpodの状態による分岐
                asyncMemos.when(
                  data: (items) {
                    // 検索ワードでフィルタリング
                    final filteredItems = items.where((memo) {
                      final query = searchQuery.toLowerCase();
                      return memo.body.toLowerCase().contains(query);
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              searchQuery.isEmpty
                                  ? 'メモルちゃんがメモを欲しそうに...'
                                  : 'みつかりませんでした',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            if (searchQuery.isEmpty)
                              const Text(
                                'さっそくメモを作成しましょう！',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) =>
                          MemoCard(memo: filteredItems[index]),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                    );
                  },
                  error: (err, stack) =>
                      Center(child: Text('エラーが発生しました: $err')),
                  loading: () => ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: 6,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, __) => const SkeletonContainer(
                      width: double.infinity,
                      height: 80,
                      borderRadius: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Listener(
        onPointerDown: (_) => setState(() => _isFabPressed = true),
        onPointerUp: (_) {
          setState(() => _isFabPressed = false);
          // 指を離したタイミングで画面遷移
          _openNewMemo(context);
        },
        onPointerCancel: (_) => setState(() => _isFabPressed = false),
        child: AnimatedScale(
          scale: _isFabPressed ? 0.7 : 1.0, // 押すと0.7倍に縮む
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            tooltip: '新しいメモを作成するボタン',
            // Listenerでタップを検知するのでonPressedはnullにするが、
            // 色が変わらないようにbackgroundColorを明示的に指定
            onPressed: null,
            backgroundColor: Theme.of(context).primaryColor,
            elevation: _isFabPressed ? 2 : 6, // 押した時に影も少し小さくする
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _openNewMemo(BuildContext context) {
    const NewMemoRoute().push(context);
  }
}
