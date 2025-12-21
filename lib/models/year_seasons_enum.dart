enum Season { winter, spring, summer, fall }

extension SeasonExtension on Season {
  String get key => toString().split(".").last;
}
