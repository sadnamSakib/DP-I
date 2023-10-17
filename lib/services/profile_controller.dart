import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileController with ChangeNotifier{

  void pickImage(context)
  {
    showDialog(
        context: context,
        builder: (BuildContext context){
      return AlertDialog(
        content: Container(
          height:120,
          child: Column(
            children: [
              ListTile(
                onTap: (){

                },
                leading: Icon(Icons.camera, color: Colors.black),
                title: Text('Camera'),

              ),
              ListTile(
                onTap: (){

                },
                leading: Icon(Icons.picture_in_picture, color: Colors.black),
                title: Text('Gallery'),

              )
            ],
          )
        ),
      );
    }
    );
  }
}