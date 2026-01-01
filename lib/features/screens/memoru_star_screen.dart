import 'dart:ui';
import 'package:flutter/material.dart';

class MemoruStarScreen extends StatelessWidget {
  const MemoruStarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 背景 (グラデーション)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0EAFC), // 薄い青
                  Color(0xFFCFDEF3), // 少し濃い青
                  Color(0xFFE2D1F9), // 薄い紫
                ],
              ),
            ),
          ),

          // コンテンツ
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 上部のメッセージ
                _GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: const Text(
                    'みんなの感情の気配が、この星の天気を与えています',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                // 惑星 (中央)
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE0C3FC), // 薄いピンク紫
                        Color(0xFF8EC5FC), // 薄い青
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: const Color(0xFF8EC5FC).withOpacity(0.4),
                        blurRadius: 60,
                        spreadRadius: 20,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 惑星の模様的なもの（装飾）
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 240,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(120),
                              bottomRight: Radius.circular(120),
                            ),
                          ),
                        ),
                      ),
                      // 小さな光
                      const Positioned(
                        right: 60,
                        bottom: 80,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 天気の説明
                _GlassContainer(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: const Text(
                    '薄い霧が、想いを包み込んでいます。',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // 統計情報
                _GlassContainer(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: [
                      // 左側：総数
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              '214',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '降り積もった想い',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 区切り線
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      // 右側：割合
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MoodRatioRow(label: '穏やか', percentage: '58%'),
                            const SizedBox(height: 4),
                            _MoodRatioRow(label: '激しい', percentage: '42%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  // final double? height;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.margin,
    this.width,
    // this.height, // 未使用のためコメントアウト
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      // height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _MoodRatioRow extends StatelessWidget {
  final String label;
  final String percentage;

  const _MoodRatioRow({required this.label, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        children: [
          Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
