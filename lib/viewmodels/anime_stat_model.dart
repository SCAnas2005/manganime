class AnimeStatModel {
  late int rankNumber;

  late int likesNumber;

  late int viewNumber;

  late int timeNumber;

  late Map<String,int> categoryPercentage; 

  void init() {
    rankNumber = 12;
    likesNumber = 1230;
    viewNumber = 2300;
    timeNumber = 32;
    categoryPercentage = {"Action":35, "Shonen":28,"Romance":18,"Fantaisie":12,"Seinen":7};
  } 
}