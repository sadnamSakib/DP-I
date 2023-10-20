class Food{
   String name;
   double protein;
   int quantity;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'protein': protein,
      'quantity': quantity,
    };
  }
  Food({required this.name, required this.protein, required this.quantity});

  static fromJson(data) {
    return Food(
      name: data['name'],
      protein: data['protein'],
      quantity: data['quantity'],
    );
  }

  toJson() {
    return {
      'name': name,
      'protein': protein,
      'quantity': quantity,
    };
  }


}
