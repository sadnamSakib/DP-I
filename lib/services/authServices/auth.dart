import 'dart:async';
import 'package:encrypt/encrypt.dart';
import 'package:design_project_1/models/UserModel.dart';
import 'package:design_project_1/services/medicineServices/medicines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'hashKey.dart';

import '../profileServices/database.dart';
class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;


  UserModel? _userFromFirebaseUser(User? user){
    return user != null  ? UserModel(uid: user.uid) : null;
  }

  Stream<UserModel?> get user{
    return _auth.authStateChanges().map(_userFromFirebaseUser);

  }


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


  Future registerWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      await user?.sendEmailVerification();
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        await DatabaseService(uid: user.uid).updateUserData(name, email);
        return _userFromFirebaseUser(user);
      } else {

        Timer? timer;
        timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
          await user?.reload();
          user = FirebaseAuth.instance.currentUser;

          if (user != null && user!.emailVerified) {

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

  Future registerWithGoogle() async{

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();


      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;


      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      User? user = result.user;
      await DatabaseService(uid: user!.uid).updateUserDataWithGoogle(user.displayName.toString(), user.email.toString(), user.photoURL.toString());
      return _userFromFirebaseUser(user);


  }



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

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      User? user = result.user;
      return _userFromFirebaseUser(user);

    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
  Future signOut() async{
    try{
      final firestoreInstance = FirebaseFirestore.instance;
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      final user = await firestoreInstance.collection('users').doc(uid).get();
      final userRole = user['role'];
      print(userRole);
      if(userRole == 'doctor'){

        await firestoreInstance.collection('doctors').doc(uid).update({
          'deviceToken': FieldValue.delete(),
        });
      }
      else{

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