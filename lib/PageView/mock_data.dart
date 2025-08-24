// mock_data.dart
class HolidayMagazine {
  final String title;
  final String description;
  final String imageUrl;

  HolidayMagazine({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

final List<HolidayMagazine> holidayMagazines = [
  HolidayMagazine(
    title: "中秋节",
    description: "花好月圆人团圆",
    imageUrl: "assets/images/mid_autumn.jpg",
  ),
  HolidayMagazine(
    title: "国庆节",
    description: "山河无恙 盛世中华",
    imageUrl: "assets/images/national_day.jpg",
  ),
];
