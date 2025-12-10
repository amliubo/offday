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
  // —————————— 2025 ——————————
  // 2025 圣诞节
  HolidayMagazine(
    title: "圣诞节",
    description: "Merry Christmas",
    imageUrl: "assets/images/christmas.jpg",
    startDate: DateTime.parse("2025-12-25"),
    endDate: DateTime.parse("2025-12-25"),
  ),

  // —————————— 2026 ——————————

  // 1. 元旦 (2026-01-01 至 2026-01-03)
  HolidayMagazine(
    title: "元旦",
    description: "新年伊始，万象更新",
    imageUrl: "assets/images/new_year_day.jpg",
    startDate: DateTime.parse("2026-01-01"),
    endDate: DateTime.parse("2026-01-03"),
  ),

  // 2. 情人节 (2026-02-14)
  HolidayMagazine(
    title: "情人节",
    description: "浪漫如期而至，爱意悄然生长",
    imageUrl: "assets/images/valentines_day.jpg",
    startDate: DateTime.parse("2026-02-14"),
    endDate: DateTime.parse("2026-02-14"),
  ),

  // 3. 春节 (2026-02-15 至 2026-02-23)
  HolidayMagazine(
    title: "春节",
    description: "阖家团圆，恭贺新禧",
    imageUrl: "assets/images/spring_festival.jpg",
    startDate: DateTime.parse("2026-02-15"),
    endDate: DateTime.parse("2026-02-23"),
  ),

  // 4. 元宵节 (2026-02-28)
  HolidayMagazine(
    title: "元宵节",
    description: "花灯明月照团圆",
    imageUrl: "assets/images/lantern_festival.jpg",
    startDate: DateTime.parse("2026-02-28"),
    endDate: DateTime.parse("2026-02-28"),
  ),

  // 5. 妇女节 (2026-03-08)
  HolidayMagazine(
    title: "妇女节",
    description: "向每一份力量与温柔致敬",
    imageUrl: "assets/images/womens_day.jpg",
    startDate: DateTime.parse("2026-03-08"),
    endDate: DateTime.parse("2026-03-08"),
  ),

  // 6. 植树节 (2026-03-12)
  HolidayMagazine(
    title: "植树节",
    description: "一棵树的希望，一个春天的开始",
    imageUrl: "assets/images/arbor_day.jpg",
    startDate: DateTime.parse("2026-03-12"),
    endDate: DateTime.parse("2026-03-12"),
  ),

  // 7. 愚人节 (2026-04-01)
  HolidayMagazine(
    title: "愚人节",
    description: "愿笑容不只在今天",
    imageUrl: "assets/images/april_fools_day.jpg",
    startDate: DateTime.parse("2026-04-01"),
    endDate: DateTime.parse("2026-04-01"),
  ),

  // 8. 清明节 (2026-04-04 至 2026-04-06)
  HolidayMagazine(
    title: "清明节",
    description: "春风拂柳，慎终追远",
    imageUrl: "assets/images/qingming_festival.jpg",
    startDate: DateTime.parse("2026-04-04"),
    endDate: DateTime.parse("2026-04-06"),
  ),

  // 9. 劳动节 (2026-05-01 至 2026-05-05)
  HolidayMagazine(
    title: "劳动节",
    description: "致敬奋斗，五一狂欢",
    imageUrl: "assets/images/labor_day.jpg",
    startDate: DateTime.parse("2026-05-01"),
    endDate: DateTime.parse("2026-05-05"),
  ),

  // 10. 母亲节 (2026-05-10)
  HolidayMagazine(
    title: "母亲节",
    description: "温柔与力量的名字叫母亲",
    imageUrl: "assets/images/mothers_day.jpg",
    startDate: DateTime.parse("2026-05-10"),
    endDate: DateTime.parse("2026-05-10"),
  ),

  // 11. 儿童节 (2026-06-01)
  HolidayMagazine(
    title: "儿童节",
    description: "愿童心永在，欢笑不散",
    imageUrl: "assets/images/childrens_day.jpg",
    startDate: DateTime.parse("2026-06-01"),
    endDate: DateTime.parse("2026-06-01"),
  ),

  // 12. 端午节 (2026-06-19 至 2026-06-21)
  HolidayMagazine(
    title: "端午节",
    description: "粽叶飘香，龙舟竞渡",
    imageUrl: "assets/images/dragon_boat.jpg",
    startDate: DateTime.parse("2026-06-19"),
    endDate: DateTime.parse("2026-06-21"),
  ),

  // 13. 父亲节 (2026-06-21)
  HolidayMagazine(
    title: "父亲节",
    description: "沉默而深沉的爱最动人",
    imageUrl: "assets/images/fathers_day.jpg",
    startDate: DateTime.parse("2026-06-21"),
    endDate: DateTime.parse("2026-06-21"),
  ),

  // 14. 七夕节 (2026-08-14)
  HolidayMagazine(
    title: "七夕节",
    description: "银河有期，与你相遇",
    imageUrl: "assets/images/qixi_festival.jpg",
    startDate: DateTime.parse("2026-08-14"),
    endDate: DateTime.parse("2026-08-14"),
  ),

  // 15. 教师节 (2026-09-10)
  HolidayMagazine(
    title: "教师节",
    description: "桃李不言，下自成蹊",
    imageUrl: "assets/images/teachers_day.jpg",
    startDate: DateTime.parse("2026-09-10"),
    endDate: DateTime.parse("2026-09-10"),
  ),

  // 16. 中秋节 (2026-09-25 至 2026-09-27)
  HolidayMagazine(
    title: "中秋节",
    description: "花好月圆人团圆",
    imageUrl: "assets/images/mid_autumn.jpg",
    startDate: DateTime.parse("2026-09-25"),
    endDate: DateTime.parse("2026-09-27"),
  ),

  // 17. 国庆节 (2026-10-01 至 2026-10-07)
  HolidayMagazine(
    title: "国庆节",
    description: "山河无恙 盛世中华",
    imageUrl: "assets/images/national_day.jpg",
    startDate: DateTime.parse("2026-10-01"),
    endDate: DateTime.parse("2026-10-07"),
  ),

  // 18. 万圣节 (2026-10-31)
  HolidayMagazine(
    title: "万圣节",
    description: "不给糖就捣蛋！",
    imageUrl: "assets/images/halloween.jpg",
    startDate: DateTime.parse("2026-10-31"),
    endDate: DateTime.parse("2026-10-31"),
  ),

  // 19. 感恩节 (2026-11-26, 美国节日)
  HolidayMagazine(
    title: "感恩节",
    description: "心怀感激，温暖常在",
    imageUrl: "assets/images/thanksgiving.jpg",
    startDate: DateTime.parse("2026-11-26"),
    endDate: DateTime.parse("2026-11-26"),
  ),

  // 20. 圣诞节 (2026-12-25)
  HolidayMagazine(
    title: "圣诞节",
    description: "Merry Christmas",
    imageUrl: "assets/images/christmas.jpg",
    startDate: DateTime.parse("2026-12-25"),
    endDate: DateTime.parse("2026-12-25"),
  ),
];
