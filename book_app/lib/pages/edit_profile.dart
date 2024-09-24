import 'dart:io';

import 'package:bookapp/const/links.dart';
import 'package:bookapp/core/elevated_button_widget.dart';
import 'package:bookapp/core/text_form_field_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.currentUserData});

  final Map<String, dynamic> currentUserData;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final ValueNotifier<bool> isNameValid = ValueNotifier(false);
  final ValueNotifier<bool> isLastnameValid = ValueNotifier(false);
  final ValueNotifier<bool> isSchoolValid = ValueNotifier(false);
  final ValueNotifier<bool> isClassValid = ValueNotifier(false);
  bool isEnable = false;

  String profileImage = "";

  @override
  void initState() {
    super.initState();
    _initProfileImage();
    _initializeControllers();
    _initializeValidators();
    _addListeners();
  }

  void _initializeControllers() {
    nameController.text = widget.currentUserData["name"] ?? "";
    lastnameController.text = widget.currentUserData["lastname"] ?? "";
    schoolController.text = widget.currentUserData["school"] ?? "";
    classController.text = widget.currentUserData["class"] ?? "";
  }

  void _initializeValidators() {
    isNameValid.value = nameController.text.isNotEmpty;
    isLastnameValid.value = lastnameController.text.isNotEmpty;
    isSchoolValid.value = schoolController.text.isNotEmpty;
    isClassValid.value = classController.text.isNotEmpty;
    _validateForm();
  }

  void _addListeners() {
    nameController.addListener(() {
      isNameValid.value = nameController.text.isNotEmpty;
    });
    lastnameController.addListener(() {
      isLastnameValid.value = lastnameController.text.isNotEmpty;
    });
    schoolController.addListener(() {
      isSchoolValid.value = schoolController.text.isNotEmpty;
    });
    classController.addListener(() {
      isClassValid.value = classController.text.isNotEmpty;
    });

    isNameValid.addListener(_validateForm);
    isLastnameValid.addListener(_validateForm);
    isSchoolValid.addListener(_validateForm);
    isClassValid.addListener(_validateForm);
  }

  Future<void> _initProfileImage() async {
    try {
      profileImage = await FirebaseStorage.instance
          .ref("${FirebaseAuth.instance.currentUser!.uid}.png")
          .getDownloadURL();
    } catch (e) {
      profileImage = userAvatar;
    }
    setState(() {});
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final firebaseImage = await FirebaseStorage.instance
            .ref("${FirebaseAuth.instance.currentUser!.uid}.png")
            .putFile(File(image.path));
        profileImage = await firebaseImage.ref.getDownloadURL();
      } catch (e) {
        EasyLoading.showError("Resim yüklenirken hata oluştu: ${e.toString()}");
      }
      setState(() {});
    }
  }

  void _validateForm() {
    setState(() {
      isEnable = isNameValid.value &&
          isLastnameValid.value &&
          isSchoolValid.value &&
          isClassValid.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profili düzenle")),
      bottomNavigationBar: SafeArea(
        child: ElevatedButtonWidget(
          isEnable: isEnable,
          onPressed: _saveProfile,
          title: 'Kaydet',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 20),
              TextFormFieldWidget(
                hintText: 'İsim',
                controller: nameController,
                icon: Icons.person,
                isValid: isNameValid,
              ),
              TextFormFieldWidget(
                hintText: 'Soyisim',
                controller: lastnameController,
                icon: Icons.person,
                isValid: isLastnameValid,
              ),
              TextFormFieldWidget(
                hintText: 'Okul',
                controller: schoolController,
                icon: Icons.school,
                isValid: isSchoolValid,
              ),
              TextFormFieldWidget(
                hintText: 'Sınıf',
                controller: classController,
                icon: Icons.class_,
                isValid: isClassValid,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return SizedBox(
      height: 80,
      width: 80,
      child: InkWell(
        onTap: _updateProfileImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                profileImage.isNotEmpty ? profileImage : userAvatar,
              ),
            ),
            const Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    try {
      EasyLoading.show();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "name": nameController.text,
        "lastname": lastnameController.text,
        "class": classController.text,
        "school": schoolController.text,
      });
      EasyLoading.showSuccess("Kaydedildi");
    } catch (e) {
      EasyLoading.showError("Hata: ${e.toString()}");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
