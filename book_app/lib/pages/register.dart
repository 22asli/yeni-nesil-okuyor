import 'package:bookapp/pages/home.dart';
import 'package:bookapp/app.dart';
import 'package:bookapp/core/elevated_button_widget.dart';
import 'package:bookapp/core/text_form_field_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  final ValueNotifier<bool> isFirstNameValid = ValueNotifier(false);
  final ValueNotifier<bool> isLastNameValid = ValueNotifier(false);
  final ValueNotifier<bool> isEmailValid = ValueNotifier(false);
  final ValueNotifier<bool> isPasswordValid = ValueNotifier(false);
  final ValueNotifier<bool> isSchoolValid = ValueNotifier(false);
  final ValueNotifier<bool> isClassValid = ValueNotifier(false);

  bool get isFormValid {
    return isFirstNameValid.value &&
        isLastNameValid.value &&
        isEmailValid.value &&
        isPasswordValid.value &&
        isSchoolValid.value &&
        isClassValid.value;
  }

  @override
  void initState() {
    super.initState();
    final validators = [
      isFirstNameValid,
      isLastNameValid,
      isEmailValid,
      isPasswordValid,
      isSchoolValid,
      isClassValid,
    ];
    for (var validator in validators) {
      validator.addListener(_validateForm);
    }
  }

  void _validateForm() {
    setState(() {});
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    schoolController.dispose();
    classController.dispose();
    isFirstNameValid.dispose();
    isLastNameValid.dispose();
    isEmailValid.dispose();
    isPasswordValid.dispose();
    isSchoolValid.dispose();
    isClassValid.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        final user = FirebaseAuth.instance.currentUser;
        final userData = {
          'email': user!.email,
          'name': firstNameController.text,
          'lastname': lastNameController.text,
          'school': schoolController.text,
          'class': classController.text,
          'pageReads': 0,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);

        push(const HomeScreen());
      } catch (e) {
        showToast("Bilgileri kontrol ediniz");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt ol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormFieldWidget(
                hintText: 'Ad',
                controller: firstNameController,
                isValid: isFirstNameValid,
              ),
              TextFormFieldWidget(
                hintText: 'Soyad',
                controller: lastNameController,
                isValid: isLastNameValid,
              ),
              TextFormFieldWidget(
                hintText: 'Email adresi',
                controller: emailController,
                isValid: isEmailValid,
                validateEmail: true,
              ),
              TextFormFieldWidget(
                hintText: 'Şifre',
                controller: passwordController,
                isValid: isPasswordValid,
                validatePassword: true,
                isObsecure: true,
              ),
              TextFormFieldWidget(
                hintText: 'Okul',
                controller: schoolController,
                isValid: isSchoolValid,
              ),
              TextFormFieldWidget(
                hintText: 'Sınıf',
                controller: classController,
                isValid: isClassValid,
              ),
              const SizedBox(height: 20),
              ElevatedButtonWidget(
                isEnable: isFormValid,
                onPressed: _register,
                title: 'Kaydet',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
