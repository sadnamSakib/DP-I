class Medicine {
  final String brandName;
  final String dosageForm;
  final String generic;
  final String strength;
  final String manufacturer;

  Medicine({
    required this.brandName,
    required this.dosageForm,
    required this.generic,
    required this.strength,
    required this.manufacturer,
  });
  Map<String, dynamic> toMap() {
    return {
      'brandName': brandName,
      'dosageForm': dosageForm,
      'generic': generic,
      'strength': strength,
      'manufacturer': manufacturer,
    };
  }
}