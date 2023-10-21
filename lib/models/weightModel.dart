class Weight{
  final double beforeMeal;
  final double afterMeal;

  Map<String, dynamic> toMap() {
    return {
      'beforeMeal': beforeMeal,
      'afterMeal': afterMeal,
    };
  }
  Weight({required this.beforeMeal, required this.afterMeal});

}
