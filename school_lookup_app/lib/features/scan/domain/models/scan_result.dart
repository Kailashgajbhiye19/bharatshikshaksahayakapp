import 'package:hive/hive.dart';

part 'scan_result.g.dart';

@HiveType(typeId: 0)
class ScanResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String imagePath;

  @HiveField(5)
  bool? isSynced;

  @HiveField(6)
  final String? userId;

  ScanResult({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    required this.imagePath,
    this.isSynced = false,
    this.userId,
  });
}
