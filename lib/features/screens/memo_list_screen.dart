import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memomemo/gen/assets.gen.dart';

import '../../core/domain/memo.dart';
import '../../core/provider/memo_state.dart';
import '../../core/provider/search_state.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/skeleton_container.dart';
import '../widgets/memo_card.dart';

class MemoListScreen extends ConsumerStatefulWidget {
  const MemoListScreen({super.key});

  @override
  ConsumerState<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends ConsumerState<MemoListScreen> {
  late final TextEditingController _searchController;

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
    return Scaffold(
      appBar: const _MemoListAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(controller: _searchController),
          const SizedBox(height: 12),
          const Expanded(child: _MemoContentArea()),
        ],
      ),
      floatingActionButton: _AnimatedFab(
        onPressed: () => const NewMemoRoute().push<void>(context),
      ),
    );
  }
}

class _MemoListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MemoListAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('気分でメモル'),
      actions: [
        IconButton(
          tooltip: '設定画面を開くボタン',
          onPressed: () => const SettingsRoute().go(context),
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.black38),
          hintText: 'けんさく',
          hintStyle: const TextStyle(color: Colors.black38),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // プロバイダーとコントローラーの両方をクリア
                    ref.read(searchQueryProvider.notifier).state = '';
                    controller.clear();
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
    );
  }
}

class _MemoContentArea extends StatelessWidget {
  const _MemoContentArea();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Assets.images.memomemo.image(),
          ),
        ),
        const _MemoList(),
      ],
    );
  }
}

class _MemoList extends ConsumerWidget {
  const _MemoList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMemos = ref.watch(memoNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return asyncMemos.when(
      data: (items) {
        final filteredItems = _filterMemos(items, searchQuery);

        if (filteredItems.isEmpty) {
          return _EmptyState(isEmptySearch: searchQuery.isEmpty);
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filteredItems.length,
          itemBuilder: (_, index) => MemoCard(memo: filteredItems[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
        );
      },
      error: (err, _) => Center(child: Text('エラーが発生しました: $err')),
      loading: () => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => const SkeletonContainer(
          width: double.infinity,
          height: 80,
          borderRadius: 12,
        ),
      ),
    );
  }

  List<Memo> _filterMemos(List<Memo> items, String query) {
    if (query.isEmpty) {
      return items;
    }
    final lowerQuery = query.toLowerCase();
    return items
        .where((memo) => memo.body.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isEmptySearch});

  final bool isEmptySearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEmptySearch ? 'メモルちゃんがメモを欲しそうに...' : 'みつかりませんでした',
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          if (isEmptySearch)
            const Text(
              'さっそくメモを作成しましょう！',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
        ],
      ),
    );
  }
}

class _AnimatedFab extends StatefulWidget {
  const _AnimatedFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 200), // アニメーションの時間を指定
        child: FloatingActionButton(
          tooltip: '新しいメモを作成するボタン',
          onPressed: null, // Listenerでタップを検知
          backgroundColor: Theme.of(context).primaryColor,
          elevation: _isPressed ? 2 : 6,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
