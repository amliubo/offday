import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:offday/PageView/CarouselSlider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.local);
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

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
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _initNotifications();
    _init();
    Connectivity().onConnectivityChanged.listen((result) {
      final connected = result != ConnectivityResult.none;
      if (mounted) {
        setState(() => isConnected = connected);
        if (connected && isLoading) _load();
      }
    });
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print('用户点击通知: ${details.payload}');
      },
    );
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'holiday_channel',
          '假期提醒',
          channelDescription: '假期星球通知',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: 'holiday_payload',
    );
  }

  Future<void> scheduleHolidayNotification() async {
    final scheduledTime = tz.TZDateTime(
      tz.local,
      holidayDate.year,
      holidayDate.month,
      holidayDate.day - 1,
      9,
    );
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      '假期提醒',
      '距离 $nextHolidayName 还有 1 天！',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'holiday_channel',
          '假期提醒',
          channelDescription: '假期星球通知',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _init() async {
    try {
      final result = await Connectivity().checkConnectivity();
      isConnected = result != ConnectivityResult.none;
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
      scheduleHolidayNotification();
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
    final h = diff.inHours % 24;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    setState(() {
      detailed =
          '${h.toString().padLeft(2, '0')}时 ${m.toString().padLeft(2, '0')}分 ${s.toString().padLeft(2, '0')}秒';
    });
    if (diff.inHours == 24 && diff.inMinutes == 0 && diff.inSeconds == 0) {
      showNotification('假期提醒', '距离 $nextHolidayName 还有 1 天！');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgController.dispose();
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
            AnimatedBuilder(
              animation: _bgController,
              builder: (_, __) {
                return _DynamicBlobs(animationValue: _bgController.value);
              },
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      child: HolidayMagazineView(),
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
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: excuse));
                      },
                      onChange: () {
                        setState(() {
                          const samples = [
                            '家里有急事，需要请假一天。',
                            '身体不适，想去看个医生。',
                            '家里停水停电，需要在家处理。',
                            '朋友结婚，要去参加婚礼。',
                            '小孩发烧了，需要陪同就医。',
                          ];
                          final shuffled = List<String>.from(samples)
                            ..shuffle();
                          excuse = shuffled.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '© 2025 假期星球',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
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

// 背景动态气泡
class _DynamicBlobs extends StatelessWidget {
  final double animationValue;
  const _DynamicBlobs({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -60 + animationValue * 30,
            top: -80 + animationValue * 20,
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
            right: -40 - animationValue * 20,
            bottom: -60 - animationValue * 10,
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
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.25)),
            ),
          ),
        ],
      ),
    );
  }
}

// Full cover loading/error
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
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _GradientNumber('$days'),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '天',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                detailed,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
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
        colors: [Color(0xFFFFE57F), Color(0xFFFFC107)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, rect.width, rect.height)),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 12, color: Colors.black38, offset: Offset(0, 4)),
          ],
        ),
      ),
    );
  }
}

class _ExcuseCard extends StatelessWidget {
  final String text;
  final VoidCallback onChange;
  final VoidCallback onCopy;
  const _ExcuseCard({
    required this.text,
    required this.onChange,
    required this.onCopy,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onChange,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('再来一个'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onCopy,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('复制理由'),
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
  final String text;
  final Uri url;
  const _LinkSmall(this.text, this.url);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
