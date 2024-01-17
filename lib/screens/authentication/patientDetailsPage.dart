import 'package:design_project_1/services/profileServices/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/authServices/auth.dart';
import '../wrapper.dart';
import 'DegreeCheckBox.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';


class PatientDetailsPage extends StatefulWidget {
  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String phone = '';
  String emergencyPhone = '';
  String error = '';
  String address = '';
  String gender ='';
  @override
  void initState() {
    super.initState();
    setState(() {
      gender="Male";
    });
  }
  List<String> preExistingConditions = [];
  List<String> commonConditions = [
    'Hypertension (High Blood Pressure)',
    'Diabetes',
    'Asthma',
    'Chronic Obstructive Pulmonary Disease (COPD)',
    'Heart Disease',
    'Cancer',
    'Autoimmune Disorders',
    'Thyroid Disorders',
    'Kidney Disease',
    'Epilepsy',
    'Mental Health Conditions',
    'Obesity',
    'Osteoporosis',
    'Chronic Migraines',
  ];

  List<bool> checkedConditions = List.filled(14, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        height: 800,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // colors: [Colors.white70, Colors.blue.shade200],
            colors: [Colors.white70, Colors.blue.shade100],
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

                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    if (number.phoneNumber != null) {
                      final formattedPhoneNumber = number.phoneNumber.toString();
                      setState(() {
                        emergencyPhone = formattedPhoneNumber;
                        print("eta current number : " + emergencyPhone + " " + (emergencyPhone.length).toString() + " " + (emergencyPhone.startsWith('+8801')).toString() );
                        if(emergencyPhone!='' && emergencyPhone.length==14 && emergencyPhone.startsWith('+8801')){
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
                    labelText: 'Emergency Contact',
                  ),
                  formatInput: false,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (val) =>
                  val!.isEmpty ? 'Please enter your address' : null,
                  onChanged: (val) {
                    setState(() => address = val);
                  },
                ),
                SizedBox(height: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your gender:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  children: [
                    ChoiceChip(
                      label: Text('Male'),
                      selected: gender == 'Male',
                      selectedColor: Colors.blue,
                      onSelected: (selected) {
                        setState(() {
                          gender = 'Male';
                          print("On selecting male : " + gender);
                        });
                      },

                    ),
                    ChoiceChip(
                      label: Text('Female'),
                      selected: gender == 'Female',
                      selectedColor: Colors.blue,
                      onSelected: (selected) {
                        setState(() {
                          gender = 'Female';
                          print("On selecting Female : " + gender);
                        });
                      },

                    ),
                  ],
                ),

              ],
            ),

                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    onPrimary: Colors.white,
                    fixedSize: const Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    _showDegreeSelection(
                        context); // Show the degree selection modal bottom sheet
                  },
                  child: Text('Select Pre Existing Conditions'),
                ),
                SizedBox(height: 10.0),
                // Display selected degrees
                Text('Pre-Existing Conditions: ${preExistingConditions.join(", ")}'),
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    onPrimary: Colors.white,
                    fixedSize: const Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () async {
                    // Submit the form and handle doctor registration here
                    if (_formKey.currentState!.validate()) {
                      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).updatePatientData(gender,
                          phone, address, emergencyPhone, preExistingConditions);
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
            itemCount: commonConditions.length,
            itemBuilder: (context, index) {
              final degree = commonConditions[index];
              return DegreeCheckbox(
                degree: degree,
                isChecked: checkedConditions[index],
                onChecked: (bool value) {
                  setState(() {
                    checkedConditions[index] = value;
                    if (value) {
                      preExistingConditions.add(degree);
                    } else {
                      preExistingConditions.remove(degree);
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
