import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/BookAppointment/doctorFinderPage.dart';
import 'package:design_project_1/services/paymentServices/Store_Credentials.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';

import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/AppointmentModel.dart';
import '../../screens/patientInterface/viewAppointment/appointmentList.dart';

class SSLCommerze extends StatefulWidget {
  final String appointmentID;
  final Appointment appointment;
  final String fee;
  const SSLCommerze({Key? key, required this.appointmentID,required this.appointment, required this.fee}) : super(key: key);

  @override
  State<SSLCommerze> createState() => _SSLCommerzeState();
}

class _SSLCommerzeState extends State<SSLCommerze> {
  var _key = GlobalKey<FormState>();
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

   String name="",phoneNumber="";


  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  dynamic formData = {};

  Future<void> fetchData() async {
    try {
      CollectionReference<Map<String, dynamic>> users =
      FirebaseFirestore.instance.collection('patients');

      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await users.doc(userUID).get();

      if (snapshot.exists) {
         name = snapshot.get('name');
         phoneNumber = snapshot.get('phone');

         nameController.text=name;
         phoneController.text=phoneNumber;

        print('Name: $name, Phone: $phoneNumber');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState(){
    super.initState();


    fetchData();

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DocLinkr'),
          backgroundColor: Colors.blue.shade900,

        ),
        body:
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white70, Colors.blue.shade100],
              ),
            ),
            child: Center(
              child: Form(
                key: _key,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 400,
                            child: TextFormField(
                              enabled: false,
                              controller: nameController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                                labelText: 'Name',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                              ),
                              // validator: (value) {
                              //   if (value != null)
                              //     return "Please input Name";
                              //   else
                              //     return null;
                              // },
                              onSaved: (value) {
                                formData['Name'] = value;
                              },
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 400,

                            child: TextFormField(
                              enabled: false,
                              controller: phoneController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              labelText: 'Phone',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              ),
                              // validator: (value) {
                              //   if (value != null)
                              //     return "Please input Name";
                              //   else
                              //     return null;
                              // },
                              onSaved: (value) {
                                formData['Phone'] = value;
                              },
                            ),
                          ),
                        ),

                        ElevatedButton(
                          child: Text("Proceed to Pay"),
                          onPressed: () {
                            if (_key.currentState != null) {
                              _key.currentState?.save();
                              // print(_radioSelected);
                              sslCommerzGeneralCall();
                              // sslCommerzCustomizedCall();
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

      ),
    );
  }

  Future<void> sslCommerzGeneralCall() async {
    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(

        multi_card_name: 'BRAC VISA',
        currency: SSLCurrencyType.BDT,
        product_category: "Appointment",
        sdkType: 'TESTBOX',

        store_id: store_ID,
        store_passwd: store_password,
        total_amount: double.parse(widget.fee),
        tran_id: "12393",
      ),
    );
    try {
      SSLCTransactionInfoModel result = await sslcommerz.payNow();

      if (result.status!.toLowerCase() == "failed") {
        Fluttertoast.showToast(
          msg: "Transaction is Failed.Please try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('faileddddddddddddddddddd');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentListPage()),
        );

      } else if (result.status!.toLowerCase() == "closed") {
        Fluttertoast.showToast(
          msg: "Portal Closed by User",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentListPage()),
        );

      } else {
        try {
          final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');

          final appointmentDoc = appointmentsCollection.doc(widget.appointmentID);

          await appointmentDoc.update({
            'isPaid': !widget.appointment.isPaid,
          }).then((_) {
            print('Payment status updated for appointment');
            Fluttertoast.showToast(
                msg:
                "Transaction is successfull",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: 16.0);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const AppointmentListPage()),
            );
          }).
          catchError((error) {
            print('Error updating appointment: $error');
            Fluttertoast.showToast(
                msg:
                "Payment Updated Successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const AppointmentListPage()),
            );
          });




        } catch (e) {
          print('Error updating payment status: $e');
        }

      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }


}
