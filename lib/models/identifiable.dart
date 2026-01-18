import 'package:flutter_application_1/models/identifiable_enums.dart';

abstract class Identifiable {
  int get id;
  String get title;
  String get synopsis;
  String get imageUrl;
  MediaStatus get status;
  double? get score;
  List<Genres> get genres;

  DateTime? get startDate;
  DateTime? get endDate;

  Map<String, dynamic> toJson();
}
