import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth extends ChangeNotifier {
  final googleSignIn =
      GoogleSignIn.standard(); //scopes: [driveApi.DriveApi.driveScope]
  GoogleSignInAccount? _user;
  GoogleSignInAccount? get user => _user;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      //show select account popup
      if (googleUser == null) return;
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      //get the credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      //sign in with firebase
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (err) {
      print(err.toString());
    }
    notifyListeners();
  }

  Future signOut() async {
    final googleUser = await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
    _user = googleUser;
    notifyListeners();
  }
}
