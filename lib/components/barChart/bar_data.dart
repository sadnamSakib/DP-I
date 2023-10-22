import 'package:design_project_1/components/barChart/individual_bar.dart';

class BarData{
  List<double> values1 = [];
  List<double>values2 = [];

  BarData({required this.values1, required this.values2});
  List<IndividualBar> barData = [];
  void initializeBarData(){
    for(int i = 0; i < values1.length; i++){
      barData.add(IndividualBar(x: i, y1: values1[i] , y2: values2[i]));
    }
  }
}