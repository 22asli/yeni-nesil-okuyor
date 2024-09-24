import 'package:bookapp/pages/edit_profile.dart';
import 'package:bookapp/widgets/loading.dart';
import 'package:bookapp/app.dart';
import 'package:bookapp/const/links.dart';
import 'package:bookapp/widgets/promo_link_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  QuerySnapshot<Map<String, dynamic>>? books;
  Map<String, dynamic>? currentUserData;
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
  }

  Future<void> getBooks() async {
    books = await FirebaseFirestore.instance
        .collection("books")
        .where("user", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  Future<void> getCurrentUserData() async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      currentUserData = userData.data();

      profileImage = await _getProfileImage();

      await getBooks();
      setState(() {});
    } catch (e) {
      await getBooks();
      setState(() {});
    }
  }

  Future<String> _getProfileImage() async {
    try {
      return await FirebaseStorage.instance
          .ref("${FirebaseAuth.instance.currentUser!.uid}.png")
          .getDownloadURL();
    } catch (e) {
      return userAvatar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              navigator.currentState!.popUntil((e) => e.isFirst);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: currentUserData == null
          ? const Loading()
          : SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildProfileHeader(),
                          const SizedBox(height: 40),
                          const Text(
                            'Kitaplarım',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildBooksList(),
                        ],
                      ),
                    ),
                  ),
                  const PromoLinkWidget(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profileImage),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        "${currentUserData!["name"] ?? ""} ${currentUserData!["lastname"] ?? ""}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(
                              currentUserData: currentUserData!,
                            ),
                          ),
                        );
                        getCurrentUserData();
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
                Text(currentUserData!["school"] ?? ""),
                const SizedBox(height: 5),
                Text(currentUserData!["class"] ?? ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    if (books == null) return Container();
    if (books!.size == 0) return const Text("Henüz kitap okumadınız");

    return Column(
      children: books!.docs.map((d) {
        final bookData = d.data();
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            title: Text(bookData["bookTitle"]),
            leading: Icon(
              bookData["recommended"] ?? false
                  ? Icons.thumb_up
                  : Icons.thumb_down,
              color:
                  bookData["recommended"] ?? false ? Colors.green : Colors.red,
            ),
          ),
        );
      }).toList(),
    );
  }
}
