import 'package:bookapp/pages/user_details_screen.dart';
import 'package:bookapp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    getPageReads();
  }

  List<Map<String, dynamic>> users = [];

  Future<void> getPageReads() async {
    QuerySnapshot<Map<String, dynamic>> userSnapshots =
        await FirebaseFirestore.instance.collection("users").get();

    for (var userDoc in userSnapshots.docs) {
      String userId = userDoc.id;
      int totalPageReads = await _getUserTotalPageReads(userId);

      users.add({
        'userId': userId,
        'name': userDoc.data()['name'],
        'lastname': userDoc.data()['lastname'],
        'pageReads': totalPageReads,
      });
    }

    // Sayfa okuma sayısına göre kullanıcıları sırala
    users.sort((a, b) => b['pageReads'].compareTo(a['pageReads']));

    setState(() {});
  }

  Future<int> _getUserTotalPageReads(String userId) async {
    QuerySnapshot<Map<String, dynamic>> bookSnapshots = await FirebaseFirestore
        .instance
        .collection("books")
        .where("user", isEqualTo: userId)
        .get();

    int totalPageReads = 0;
    for (var bookDoc in bookSnapshots.docs) {
      totalPageReads += (bookDoc.data()['totalPagesRead'] as num).toInt();
    }

    return totalPageReads;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liderlik Sıralaması'),
      ),
      body: users.isEmpty
          ? const Loading()
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title:
                      Text('${user["name"] ?? ""} ${user["lastname"] ?? ""}'),
                  subtitle: Text('${user["pageReads"]} sayfa okudu'),
                  onTap: () => _navigateToUserDetailPage(user, index),
                );
              },
            ),
    );
  }

  void _navigateToUserDetailPage(Map<String, dynamic> user, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(
          user: user,
          ref: FirebaseFirestore.instance
              .collection("users")
              .doc(user['userId']),
        ),
      ),
    );
  }
}
