import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const OffDayApp());
}

class OffDayApp extends StatelessWidget {
  const OffDayApp({super.key});
  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: 'SF Pro Text',
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: baseTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String? error;
  bool isConnected = true;

  String nextHolidayName = '';
  DateTime holidayDate = DateTime.now().add(const Duration(days: 15));
  String excuse = '家里有急事，需要请假一天。';
  String detailed = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
    Connectivity().onConnectivityChanged.listen((result) {
      final connected =
          result.isNotEmpty && !result.contains(ConnectivityResult.none);
      if (mounted) {
        setState(() => isConnected = connected);
        if (connected && isLoading) _load();
      }
    });
  }

  Future<void> _init() async {
    try {
      final result = await Connectivity().checkConnectivity();
      // 新版本返回 List<ConnectivityResult>
      isConnected =
          result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } catch (e) {
      isConnected = false;
    }
    if (!mounted) return;
    if (!isConnected) {
      setState(() {
        isLoading = false;
        error = '网络不可用，请检查您的网络连接';
      });
      return;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final uri = Uri.parse(
        'https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/2025.json',
      );
      final resp = await http.get(uri);
      if (resp.statusCode != 200) throw Exception('加载失败');
      final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
      final days = (jsonMap['days'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final now = DateTime.now();
      final fmt = DateFormat('yyyy-MM-dd');
      final upcoming =
          days
              .map((e) => {'name': e['name'], 'date': fmt.parse(e['date'])})
              .where(
                (e) =>
                    (e['date'] as DateTime).isAfter(now) ||
                    _isSameDay(e['date'] as DateTime, now),
              )
              .toList()
            ..sort(
              (a, b) =>
                  (a['date'] as DateTime).compareTo(b['date'] as DateTime),
            );
      if (upcoming.isEmpty) throw Exception('没有找到下一个假期');
      setState(() {
        nextHolidayName = upcoming.first['name'] as String;
        holidayDate = upcoming.first['date'] as DateTime;
        isLoading = false;
      });
      _startTick();
    } catch (e) {
      setState(() {
        isLoading = false;
        error = '加载假期数据失败，请稍后重试';
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _startTick() {
    _timer?.cancel();
    _updateDetailed();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDetailed(),
    );
  }

  void _updateDetailed() {
    final now = DateTime.now();
    final diff = holidayDate.difference(now);
    // final d = diff.inDays;
    final h = diff.inHours % 24;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    setState(() {
      detailed =
          '${h.toString().padLeft(2, '0')}时 ${m.toString().padLeft(2, '0')}分 ${s.toString().padLeft(2, '0')}秒';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color(0xFF4F5D75), Color(0xFF6C63FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    Widget page;
    if (isLoading) {
      page = _FullCover(
        bg: bgGradient,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text('假期星球 加载中...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else if (!isConnected || error != null) {
      page = _FullCover(
        bg: bgGradient,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              error != null ? Icons.error_outline : Icons.wifi_off,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? '网络不可用，请检查您的网络连接',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _load,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    } else {
      page = Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          children: [
            const _StaticBlobs(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '假期星球',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '下一次放松，不再遥远',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _CountdownCard(
                      title: '距离 $nextHolidayName',
                      days: _daysBetween(DateTime.now(), holidayDate),
                      detailed: detailed,
                    ),
                    const SizedBox(height: 24),
                    _ExcuseCard(
                      text: excuse,
                      onChange: () {
                        setState(() {
                          const samples = [
                            '家里有急事，需要请假一天。',
                            '身体不适，想去看个医生。',
                            '家里停水停电，需要在家处理。',
                            '朋友结婚，要去参加婚礼。',
                            '小孩发烧了，需要陪同就医。',
                            '家里水管爆了，需要紧急维修。',
                            '父母身体不舒服，需要陪同检查。',
                            '家里装修，需要在家监工。',
                            '车坏了，需要去修理厂。',
                            '家里有亲戚来访，需要接待。',
                            '身体有点感冒，想休息一天。',
                            '家里网络故障，需要等维修人员。',
                            '宠物生病了，需要带去宠物医院。',
                            '家里有重要快递，需要在家签收。',
                            '身体疲劳，想调整一下状态。',
                            '家里有紧急文件需要处理。',
                            '身体过敏，需要去医院检查。',
                            '家里有老人需要照顾。',
                            '身体有点不舒服，想在家休息。',
                            '家里有突发情况需要处理。',
                          ];
                          final shuffled = List<String>.from(samples)
                            ..shuffle();
                          excuse = shuffled.first;
                        });
                      },
                    ),
                    const Spacer(),
                    Text(
                      '© 2025 假期星球',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 16,
                      children: [
                        _LinkSmall(
                          '隐私政策',
                          Uri.parse(
                            'https://liubodev.top/OffDay-privacy.zh-Hans.html',
                          ),
                        ),
                        _LinkSmall(
                          '用户协议',
                          Uri.parse(
                            'https://liubodev.top/OffDay-user-agreement.zh-Hans.html',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(body: page);
  }

  int _daysBetween(DateTime a, DateTime b) {
    final start = DateTime(a.year, a.month, a.day);
    final end = DateTime(b.year, b.month, b.day);
    return end.difference(start).inDays;
  }
}

class _FullCover extends StatelessWidget {
  final Gradient bg;
  final Widget child;
  const _FullCover({required this.bg, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: bg),
      child: Center(child: child),
    );
  }
}

class _StaticBlobs extends StatelessWidget {
  const _StaticBlobs();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -60,
            top: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
              ),
            ),
          ),
          Positioned(
            right: -40,
            bottom: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                ),
              ),
            ),
          ),
          // 轻量模糊遮罩弱化饱和度
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final String title;
  final int days;
  final String detailed;
  const _CountdownCard({
    required this.title,
    required this.days,
    required this.detailed,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _GradientNumber('$days'),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '天',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  detailed,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientNumber extends StatelessWidget {
  final String text;
  const _GradientNumber(this.text);
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        colors: [Colors.white, Color(0xCCFFFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 92,
          fontWeight: FontWeight.w900,
          height: 1.0,
          shadows: [
            Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 6)),
          ],
        ),
      ),
    );
  }
}

class _ExcuseCard extends StatelessWidget {
  final String text;
  final VoidCallback onChange;
  const _ExcuseCard({required this.text, required this.onChange});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '请假理由',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onChange,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '再来一个',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('请假理由已复制到剪贴板'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '复制理由',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkSmall extends StatelessWidget {
  final String label;
  final Uri url;
  const _LinkSmall(this.label, this.url);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(url, mode: LaunchMode.externalApplication),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
