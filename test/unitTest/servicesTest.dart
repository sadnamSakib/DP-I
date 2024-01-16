import 'package:agora_uikit/controllers/rtc_buttons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_project_1/services/authServices/auth.dart';
void main() {
  setUpAll(() async {
    await Firebase.initializeApp();

  });
  test('Test encryption', () {

      String text = "Hello World";
      AuthService _auth = AuthService();
      String encryptedText = _auth.encrypt(text);
      String decryptedText = _auth.decrypt(encryptedText);
      expect(text, decryptedText);
  });
}