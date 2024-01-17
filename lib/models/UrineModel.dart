class Urine {
  double volume;
  String color;
  final String time;
  late final String date;

  Map<String, dynamic> toMap() {
    return {
      'volume': volume,
      'color': color,
      'date': date,
      'time': time,
    };
  }

  void DateFormatter(DateTime date){
    this.date = date.year.toString() + "-" + date.month.toString() + "-" + date.day.toString();
  }

  Urine({required this.volume, required this.color, required this.time}) {
    DateFormatter(DateTime.now());
  }
}
