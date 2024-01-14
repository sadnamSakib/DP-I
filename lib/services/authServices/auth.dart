import 'dart:async';
import 'package:encrypt/encrypt.dart';
import 'package:design_project_1/models/UserModel.dart';
import 'package:design_project_1/services/medicineServices/medicines.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'hashKey.dart';

import '../profileServices/database.dart';
class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user object based on firebase user
  UserModel? _userFromFirebaseUser(User? user){
    return user != null  ? UserModel(uid: user.uid) : null;
  }
  //auth change user stream
  Stream<UserModel?> get user{
    return _auth.authStateChanges().map(_userFromFirebaseUser);
    //.map((User? user) => _userFromFirebaseUser(user));
  }

  //sign in anon
  Future signInAnon() async{
    try{
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  //register with email and password
  Future registerWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      await user?.sendEmailVerification();
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // Email is verified, store the user's information in Firestore.
        await DatabaseService(uid: user.uid).updateUserData(name, email);
        return _userFromFirebaseUser(user);
      } else {
        // Handle cases where the email is not verified yet.
        // Start a timer to periodically check if the email has been verified.
        Timer? timer;
        timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
          await user?.reload();
          user = FirebaseAuth.instance.currentUser;

          if (user != null && user!.emailVerified) {
            // Email is now verified, update Firestore and cancel the timer.
            await DatabaseService(uid: user!.uid).updateUserData(name, email);
            timer.cancel();
          }
        });

        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
//register with google
  Future registerWithGoogle() async{
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      User? user = result.user;
      await DatabaseService(uid: user!.uid).updateUserDataWithGoogle(user.displayName.toString(), user.email.toString(), user.photoURL.toString());
      return _userFromFirebaseUser(user);

      // return _userFromFirebaseUser(user);
  }


  //sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future signInWithGoogle() async{
    try{
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      User? user = result.user;
      return _userFromFirebaseUser(user);

      // return _userFromFirebaseUser(user);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
  //sign out
  Future signOut() async{
    try{
      final firestoreInstance = FirebaseFirestore.instance;
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      final user = await firestoreInstance.collection('users').doc(uid).get();
      final userRole = user['role'];
      print(userRole);
      if(userRole == 'doctor'){
        //delete devictoken from the doctor
        await firestoreInstance.collection('doctors').doc(uid).update({
          'deviceToken': FieldValue.delete(),
        });
      }
      else{
        //delete devictoken from the patient
        await firestoreInstance.collection('patients').doc(uid).update({
          'deviceToken': FieldValue.delete(),
        });
      }
      print("logging out");
      return await _auth.signOut();
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  String decrypt( String encryptedData) {
    String hash = HashKey.toString();
    final key = Key.fromUtf8(hash);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(hash.substring(0, 16));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedData), iv: initVector);
    return decrypted;
  }

  String encrypt( String plainText) {
    String hash = HashKey.toString();
    final key = Key.fromUtf8(hash);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(hash.substring(0, 16));
    Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
    return encryptedData.base64;
  }
}