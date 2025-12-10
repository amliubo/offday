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
  Map<String, int>? countdown;

  @override
  void initState() {
    super.initState();
    _currentIndex = _findNearestHolidayIndex();
    _updateCountdown();
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

  void _updateCountdown() {
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

    setState(() {
      countdown = {
        'days': diff.inDays,
        'hours': diff.inHours % 24,
        'minutes': diff.inMinutes % 60,
        'seconds': diff.inSeconds % 60,
        'isOngoing': isOngoing ? 1 : 0,
      };
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _updateCountdown();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景滑动层
          PageView.builder(
            controller: _pageController,
            itemCount: widget.holidays.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _updateCountdown();
            },
            itemBuilder: (context, index) {
              return Image.asset(
                widget.holidays[index].imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
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
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
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
                        overflow: TextOverflow.visible,
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
                    height: 1,
                  ),
                ),
                const SizedBox(height: 18),
                // 小圆点指示器
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  children: List.generate(widget.holidays.length, (index) {
                    final bool selected = _currentIndex == index;
                    return Container(
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
                // 协议链接弹窗
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      _buildProtocolLinkDialog(
                        "隐私协议",
                        "https://amliubo.github.io/app-policies/OffDay-privacy.zh-Hans.html",
                      ),
                      const SizedBox(width: 12),
                      _buildProtocolLinkDialog(
                        "用户协议",
                        "https://amliubo.github.io/app-policies/OffDay-user-agreement.zh-Hans.html",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProtocolLinkDialog(String text, String url) {
    return InkWell(
      onTap: () {
        _showWebViewDialog(text, url);
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 12,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  void _showWebViewDialog(String title, String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "WebViewDialog",
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.85,
                color: Colors.white,
                child: Column(
                  children: [
                    // 顶部标题栏
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(child: WebViewWidget(controller: controller)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
