import 'PrescribedMedicineModel.dart';
class PrescriptionModel{
  String patientId;
  String doctorId;
  String date;
  List<PrescribeMedicineModel>prescribedMedicines;
  PrescriptionModel({required this.patientId,required this.doctorId,required this.date,required this.prescribedMedicines});

  Map<String,dynamic>toMap(){
    return{
      'patientId':patientId,
      'doctorId':doctorId,
      'date':date,
      'prescribedMedicines':prescribedMedicines.map((e) => e.toMap()).toList(),
    };
  }

  static fromMap(Map<String,dynamic>map){
    return PrescriptionModel(
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      date: map['date'],
      prescribedMedicines: map['prescribedMedicines'],
    );
  }


}