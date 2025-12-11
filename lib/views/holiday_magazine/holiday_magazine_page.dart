import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../mock_data.dart';

class HolidayMagazinePage extends StatefulWidget {
  final List<HolidayMagazine> holidays;

  const HolidayMagazinePage({super.key, required this.holidays});

  @override
  State<HolidayMagazinePage> createState() => _HolidayMagazinePageState();
}

class _HolidayMagazinePageState extends State<HolidayMagazinePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _prevIndex = 0;
  Map<String, int>? countdown;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = _findNearestHolidayIndex();
    _prevIndex = _currentIndex;
    _startCountdown();

    // 预缓存所有本地图片
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var holiday in widget.holidays) {
        precacheImage(AssetImage(holiday.imageUrl), context);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  int _findNearestHolidayIndex() {
    final now = DateTime.now();
    for (int i = 0; i < widget.holidays.length; i++) {
      final h = widget.holidays[i];
      if (now.isBefore(
        _getHolidayEndWithTime(h).add(const Duration(seconds: 1)),
      )) {
        return i;
      }
    }
    return 0;
  }

  DateTime _getHolidayEndWithTime(HolidayMagazine holiday) => DateTime(
    holiday.endDate.year,
    holiday.endDate.month,
    holiday.endDate.day,
    23,
    59,
    59,
  );

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final holiday = widget.holidays[_currentIndex];
      final now = DateTime.now();
      Duration diff;
      bool isOngoing = false;

      final holidayEnd = _getHolidayEndWithTime(holiday);

      if (now.isBefore(holiday.startDate)) {
        diff = holiday.startDate.difference(now);
      } else if (now.isAfter(holidayEnd)) {
        diff = now.difference(holidayEnd);
      } else {
        isOngoing = true;
        diff = holidayEnd.difference(now);
      }

      countdown = {
        'days': diff.inDays,
        'hours': diff.inHours % 24,
        'minutes': diff.inMinutes % 60,
        'seconds': diff.inSeconds % 60,
        'isOngoing': isOngoing ? 1 : 0,
      };
      setState(() {});
    });
  }

  String _formatCountdown(Map<String, int> cd, {bool isPast = false}) {
    final days = cd['days']!;
    final h = cd['hours']!.toString().padLeft(2, '0');
    final m = cd['minutes']!.toString().padLeft(2, '0');
    final s = cd['seconds']!.toString().padLeft(2, '0');
    final timeStr = "${days > 0 ? "$days天 " : ""}$h时 $m分 $s秒";

    if (isPast) return "已过 $timeStr";
    if (cd['isOngoing'] == 1) return "剩余 $timeStr";
    return "还有 $timeStr";
  }

  @override
  Widget build(BuildContext context) {
    final holiday = widget.holidays[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景图片滑动 + 淡入动画
          PageView.builder(
            controller: _pageController,
            itemCount: widget.holidays.length,
            onPageChanged: (index) {
              setState(() {
                _prevIndex = _currentIndex;
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: Image.asset(
                  widget.holidays[_currentIndex].imageUrl,
                  key: ValueKey('bg_${_currentIndex}'),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          // 底部玻璃卡片
          Positioned(left: 0, right: 0, bottom: 0, child: _buildGlassCard()),
        ],
      ),
    );
  }

  Widget _buildGlassCard() {
    final holiday = widget.holidays[_currentIndex];
    final now = DateTime.now();
    final holidayEnd = _getHolidayEndWithTime(holiday);
    final isPast = now.isAfter(holidayEnd);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54, Colors.black87],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.9,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 标题 + 倒计时
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                holiday.title,
                                maxLines: 2,
                                minFontSize: 20,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 58,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                            ),
                            if (countdown != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _formatCountdown(countdown!, isPast: isPast),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // 描述
                        Text(
                          holiday.description,
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white70,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // 小圆点指示器
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          children: List.generate(widget.holidays.length, (
                            index,
                          ) {
                            final bool selected = _currentIndex == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: selected ? 12 : 8,
                              height: selected ? 12 : 8,
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 18),
                        // 协议链接
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () => _showBottomSheetWebView(
                                  "隐私协议",
                                  "https://amliubo.github.io/app-policies/OffDay-privacy.zh-Hans.html",
                                ),
                                child: const Text(
                                  "隐私协议",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () => _showBottomSheetWebView(
                                  "用户协议",
                                  "https://amliubo.github.io/app-policies/OffDay-user-agreement.zh-Hans.html",
                                ),
                                child: const Text(
                                  "用户协议",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheetWebView(String title, String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.35),
              height: MediaQuery.of(context).size.height * 0.9,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(child: WebViewWidget(controller: controller)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
