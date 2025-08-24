import 'package:flutter/material.dart';
import 'mock_data.dart';

class HolidayMagazineView extends StatelessWidget {
  const HolidayMagazineView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: holidayMagazines.length,
        controller: PageController(viewportFraction: 1.0), // 关键：全屏宽度
        itemBuilder: (context, index) {
          final item = holidayMagazines[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(0), // 全屏时可不加圆角
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(item.imageUrl, fit: BoxFit.cover),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Text(
                    "${item.title}\n${item.description}",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
