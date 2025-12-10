// mock_data.dart
class HolidayMagazine {
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;

  HolidayMagazine({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
  });
}

final List<HolidayMagazine> holidayMagazines = [
  // 1. 元旦 (2026-01-01 至 2026-01-03)
  HolidayMagazine(
    title: "元旦",
    description: "新年伊始，万象更新",
    imageUrl: "assets/images/new_year_day.jpg",
    startDate: DateTime.parse("2026-01-01"),
    endDate: DateTime.parse("2026-01-03"),
  ),

  // 2. 春节 (2026-02-15 至 2026-02-23)
  HolidayMagazine(
    title: "春节",
    description: "阖家团圆，恭贺新禧",
    imageUrl: "assets/images/spring_festival.jpg",
    startDate: DateTime.parse("2026-02-15"),
    endDate: DateTime.parse("2026-02-23"),
  ),

  // 3. 清明节 (2026-04-04 至 2026-04-06)
  HolidayMagazine(
    title: "清明节",
    description: "春风拂柳，慎终追远",
    imageUrl: "assets/images/qingming_festival.jpg",
    startDate: DateTime.parse("2026-04-04"),
    endDate: DateTime.parse("2026-04-06"),
  ),

  // 4. 劳动节 (2026-05-01 至 2026-05-05)
  HolidayMagazine(
    title: "劳动节",
    description: "致敬奋斗，五一狂欢",
    imageUrl: "assets/images/labor_day.jpg",
    startDate: DateTime.parse("2026-05-01"),
    endDate: DateTime.parse("2026-05-05"),
  ),

  // 5. 端午节 (2026-06-19 至 2026-06-21)
  HolidayMagazine(
    title: "端午节",
    description: "粽叶飘香，龙舟竞渡",
    imageUrl: "assets/images/dragon_boat.jpg",
    startDate: DateTime.parse("2026-06-19"),
    endDate: DateTime.parse("2026-06-21"),
  ),

  // 6. 中秋节 (2026-09-25 至 2026-09-27)
  HolidayMagazine(
    title: "中秋节",
    description: "花好月圆人团圆",
    imageUrl: "assets/images/mid_autumn.jpg",
    startDate: DateTime.parse("2026-09-25"),
    endDate: DateTime.parse("2026-09-27"),
  ),

  // 7. 国庆节 (2026-10-01 至 2026-10-07)
  HolidayMagazine(
    title: "国庆节",
    description: "山河无恙 盛世中华",
    imageUrl: "assets/images/national_day.jpg",
    startDate: DateTime.parse("2026-10-01"),
    endDate: DateTime.parse("2026-10-07"),
  ),

  // 8. 圣诞节 (2026-12-25)
  HolidayMagazine(
    title: "圣诞节",
    description: "Merry Christmas",
    imageUrl: "assets/images/christmas.jpg",
    startDate: DateTime.parse("2026-12-25"),
    endDate: DateTime.parse("2026-12-25"),
  ),
];
