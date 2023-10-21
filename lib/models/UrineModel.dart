class Urine{
  double volume;
  String color;
  final String time;
  Map<String, dynamic> toMap() {
    return {
      'volume': volume,
      'color': color,
      'time': time,
    };
  }
  Urine({required this.volume, required this.color, required this.time});
}