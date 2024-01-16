import 'package:design_project_1/screens/wrapper.dart';
import 'package:design_project_1/services/profileServices/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/authServices/auth.dart';
import 'DegreeCheckBox.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';


class DoctorDetailsPage extends StatefulWidget {
  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String phone = '';
  String specialization = '';
  String error = '';
  String chamberAddress = '';
  String medicalLicense = '';
  List<String> degrees = [];
  List<String> availableDegrees = [
    'MD', 'DO', 'MBBS', 'FCPS', 'FRCS', 'MRCP', 'MRCGP', 'MRCOG', 'MDS',
    'MS', 'MSc', 'PhD', 'Diploma'
  ];
  List<bool> checkedDegrees = List.filled(14, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.pink.shade900,
      ),
      body: Container(
        height: 800,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // colors: [Colors.white70, Colors.blue.shade200],
            colors: [Colors.white70, Colors.pink.shade100],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    if (number.phoneNumber != null) {
                      final formattedPhoneNumber = number.phoneNumber.toString();
                      setState(() {
                        phone = formattedPhoneNumber;
                        print("eta current number : " + phone + " " + (phone.length).toString() + " " + (phone.startsWith('+8801')).toString() );
                        if(phone!='' && phone.length==14 && phone.startsWith('+8801')){
                          setState(() {
                            error = '';
                          });
                        }
                        else{
                          setState(() {
                            error = 'Please enter valid phone number';
                          });
                        }
                      });
                    }
                  },
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  selectorTextStyle: TextStyle(color: Colors.black),
                  initialValue: PhoneNumber(isoCode: 'BD'),
                  inputDecoration: InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  formatInput: false,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
            const SizedBox(height: 10.0),
                DropdownButtonFormField(
                  decoration: InputDecoration(labelText: 'Specialization'),
                  value: 'INTERNAL MEDICINE',
                  items: [
                    'ANESTHESIOLOGY',
                    'CARDIAC & VASCULAR SURGERY',
                    'CARDIOLOGY (INTERVENTIONAL)',
                    'CHILD DEVELOPMENT',
                    'CLINICAL HEMATOLOGY',
                    'COLORECTAL & LAPAROSCOPIC SURGERY',
                    'DENTAL CARE, ORTHODONTICS & MAXILLOFACIAL SURGERY',
                    'DERMATOLOGY',
                    'DIET AND NUTRITION',
                    'ENDOCRINOLOGY',
                    'ENT, HEAD & NECK SURGERY',
                    'GASTROENTEROLOGY',
                    'GENERAL SURGERY',
                    'INTERNAL MEDICINE',
                    'IVF',
                    'MICROBIOLOGY',
                    'NEONATOLOGY',
                    'NEPHROLOGY',
                    'NEURO ICU',
                    'NEURO SURGERY',
                    'NEUROMEDICINE',
                    'OBGYN',
                    'ONCOLOGY',
                    'OPHTHALMOLOGY',
                    'ORTHOPEDICS',
                    'PAEDIATRIC CARDIOLOGY',
                    'PAEDIATRIC HEMATO-ONCOLOGY',
                    'PAEDIATRIC NEPHROLOGY',
                    'PAEDIATRIC SURGERY',
                    'PAEDIATRICS',
                    'PATHOLOGY & LAB. MEDICINE',
                    'PHYSICAL MEDICINE & REHABILITATION',
                    'PLASTIC SURGERY',
                    'PSYCHIATRY',
                    'RADIOLOGY & IMAGING',
                    'RESPIRATORY MEDICINE',
                    'RHEUMATOLOGY',
                    'TRANSFUSION MEDICINE (BLOOD BANK)',
                    'UROLOGY'
                  ]
                      .map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                        child: Container(
                        constraints: BoxConstraints(maxWidth: 200),
                    child: Text(
                    specialty,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    ),
                    ),

                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => specialization = val.toString());
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Chamber Address'),
                  validator: (val) =>
                  val!.isEmpty ? 'Please enter a chamber address' : null,
                  onChanged: (val) {
                    setState(() => chamberAddress = val);
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Medical License'),
                  validator: (val) =>
                  val!.isEmpty ? 'Please enter a medical license' : null,
                  onChanged: (val) {
                    setState(() => medicalLicense = val);
                  },
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal.shade800,
                  ),
                  onPressed: () {
                    _showDegreeSelection(
                        context);
                  },
                  child: Text('Select Degrees'),
                ),
                SizedBox(height: 10.0),
                // Display selected degrees
                Text('Selected Degrees: ${degrees.join(", ")}'),
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal.shade800,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).updateDoctorData(
                          phone, chamberAddress, medicalLicense,specialization, degrees);
                      SnackBar snackBar = SnackBar(content: Text('Registration Successful.Please log in to your account.'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      await _auth.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const Wrapper()));
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDegreeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: ListView.builder(
            itemCount: availableDegrees.length,
            itemBuilder: (context, index) {
              final degree = availableDegrees[index];
              return DegreeCheckbox(
                degree: degree,
                isChecked: checkedDegrees[index],
                onChecked: (bool value) {
                  setState(() {
                    checkedDegrees[index] = value;
                    if (value) {
                      degrees.add(degree);
                    } else {
                      degrees.remove(degree);
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}
