import 'MedicineModel.dart';
class PrescribeMedicineModel{
  Medicine medicineDetails;
  int days;
  Map<String,dynamic>intakeTime;
  bool isBeforeMeal;
  String? instruction="";
  PrescribeMedicineModel({required this.medicineDetails,required this.days,required this.intakeTime,required this.isBeforeMeal,this.instruction});
  Map<String,dynamic>toMap(){
    return{
      'medicineDetails':medicineDetails.toMap(),
      'days':days,
      'intakeTime':intakeTime,
      'isBeforeMeal':isBeforeMeal,
      'instruction':instruction,
    };
  }

  static fromMap(Map<String,dynamic>map){
    return PrescribeMedicineModel(
      medicineDetails: Medicine.fromMap(map['medicineDetails']),
      days: map['days'],
      intakeTime: map['intakeTime'],
      isBeforeMeal: map['isBeforeMeal'],
      instruction: map['instruction'],
    );
  }
}