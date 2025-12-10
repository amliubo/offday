import 'dart:ui';
import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../../policy_webview_page.dart';

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

  Widget _buildProtocolLink(String text, String url) {
    return InkWell(
      onTap: () {
        debugPrint("点击了 $text -> $url");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PolicyWebViewPage(url: url, title: text),
          ),
        );
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
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
          // 渐变透明卡片层
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 26),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题 + 倒计时
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        holiday.title,
                        style: const TextStyle(
                          fontSize: 58,
                          fontWeight: FontWeight.w700,
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
                            fontSize: 14,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
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
                // 协议链接
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      _buildProtocolLink(
                        "隐私协议",
                        "https://amliubo.github.io/app-policies/OffDay-privacy.zh-Hans.html",
                      ),
                      const SizedBox(width: 12),
                      _buildProtocolLink(
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
}
