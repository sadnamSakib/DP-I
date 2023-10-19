class BloodPressure{
  final int systolic;
  final int diastolic;
  final String time;

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'time': time,
    };
  }
  BloodPressure({required this.systolic, required this.diastolic, required this.time});

}
