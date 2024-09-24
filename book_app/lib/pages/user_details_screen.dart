import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatefulWidget {
  final DocumentReference<Map<String,dynamic>> ref;
  final Map<String,dynamic> user;

  UserDetailsScreen({required this.user,required this.ref});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  
  @override
  void initState() {
    
    getBooks();
    super.initState();
  }
  QuerySnapshot<Map<String,dynamic>>? books;

  getBooks()async{
    print(widget.ref.id);
    books = await FirebaseFirestore.instance.collection("books").where("user",isEqualTo: widget.ref.id).get();
    setState(() {

    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user["Ad"]} Detayları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Okuduğu Kitaplar:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if(books != null)
              Column(
                children: books!.docs.map((d)=>Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0)
                  ),
                  child: ListTile(

                    title: Text(d.data()["bookTitle"]),
                    leading:Icon(d.data()["recommended"] ?? false ? Icons.thumb_up : Icons.thumb_down,color: d.data()["recommended"] ?? false ? Colors.green: Colors.red,) ,
                  ),
                )).toList(),
              ),
            
            SizedBox(height: 20),
            Text('Tavsiye Ettiği Kitaplar:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if(books != null)
              Column(
                children: books!.docs.where((d)=>d.data()["recommended"] ?? false).map((d)=>Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0)
                  ),
                  child: ListTile(

                    title: Text(d.data()["bookTitle"]),
                    leading:Icon(d.data()["recommended"] ?? false ? Icons.thumb_up : Icons.thumb_down,color: d.data()["recommended"] ?? false ? Colors.green: Colors.red,) ,
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}