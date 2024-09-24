import 'package:bookapp/pages/register.dart';
import 'package:bookapp/app.dart';
import 'package:bookapp/core/elevated_button_widget.dart';
import 'package:bookapp/core/text_form_field_widget.dart';
import 'package:bookapp/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oktoast/oktoast.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isEnable = false;

  ValueNotifier<bool> isEmailValid = ValueNotifier(false);
  ValueNotifier<bool> isPasswordValid = ValueNotifier(false);

  @override
  void initState() {
    initFirebase();
    isEmailValid.addListener(_validateForm);
    isPasswordValid.addListener(_validateForm);
    super.initState();
  }

  void _validateForm() {
    setState(() {
      isEnable = isEmailValid.value && isPasswordValid.value;
    });
  }

  initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (FirebaseAuth.instance.currentUser != null) {
      push(const HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Yap"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                TextFormFieldWidget(
                  hintText: 'EMail',
                  validateEmail: true,
                  icon: Icons.email,
                  controller: emailController,
                  isValid: isEmailValid,
                ),
                TextFormFieldWidget(
                  hintText: 'Parola',
                  validatePassword: true,
                  icon: Icons.password,
                  controller: passwordController,
                  isObsecure: true,
                  isValid: isPasswordValid,
                ),
                ElevatedButtonWidget(
                  isEnable: isEnable,
                  onPressed: () => _signInMethod(),
                  title: 'Giriş Yap',
                ),
                InkWell(
                  onTap: _signInWithGoogleMethod,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/images/google.png", height: 40),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("Google ile giriş yap"),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _navigateRegisterScreen,
              child: const Text("Hesabınız yok mu? Kayıt olun"),
            )
          ],
        ),
      ),
    );
  }

  void _signInWithGoogleMethod() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    final google = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await google?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    final currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .set({"name": google!.displayName, "email": google.email});
    push(const HomeScreen());
  }

  void _navigateRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  Future _signInMethod() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      push(const HomeScreen());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showToast("Email veya şifre geçersiz");
      }
    }
  }

  Future<bool> isNewUser(user) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: user.email)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    return docs.isEmpty ? true : false;
  }
}
