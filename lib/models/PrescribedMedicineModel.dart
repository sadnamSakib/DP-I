import 'MedicineModel.dart';
class PrescribeMedicineModel{
  Medicine medicineDetails;
  int days;
  Map<String,bool>intakeTime;
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
}