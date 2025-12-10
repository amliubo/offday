import 'package:flutter/material.dart';
import 'views/holiday_magazine/holiday_magazine_page.dart';
import './views/mock_data.dart';

void main() {
  runApp(const HolidayApp());
}

class HolidayApp extends StatelessWidget {
  const HolidayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holiday Magazine',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,

      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),

      home: HolidayMagazinePage(holidays: holidayMagazines),
    );
  }
}
