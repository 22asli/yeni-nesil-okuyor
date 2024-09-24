import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:bookapp/core/text_form_field_widget.dart';

class DailyReadingScreen extends StatefulWidget {
  const DailyReadingScreen({super.key});

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  final TextEditingController bookTitleController = TextEditingController();
  final TextEditingController authorNameController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController dailyPagesReadController =
      TextEditingController();
  final TextEditingController mainIdeaController = TextEditingController();
  final TextEditingController yourThoughtsController = TextEditingController();

  String bookTitle = '';
  String authorName = '';
  int totalPages = 0;
  int dailyPagesRead = 0;
  int totalDailyPagesRead = 0;
  int totalPagesRead = 0;
  String mainIdea = '';
  String yourThoughts = '';
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  DocumentSnapshot<Map<String, dynamic>>? relatedBook;
  ValueNotifier<bool> isBookTitleValid = ValueNotifier(false);
  ValueNotifier<bool> isAuthorNameValid = ValueNotifier(false);
  ValueNotifier<bool> isTotalPagesValid = ValueNotifier(false);
  ValueNotifier<bool> isDailyPagesReadValid = ValueNotifier(false);
  bool isFormValid = false;

  @override
  void initState() {
    findCurrentBook();
    isBookTitleValid.addListener(_validateForm);
    isAuthorNameValid.addListener(_validateForm);
    isTotalPagesValid.addListener(_validateForm);
    isDailyPagesReadValid.addListener(_validateForm);
    super.initState();
  }

  @override
  void dispose() {
    bookTitleController.dispose();
    authorNameController.dispose();
    totalPagesController.dispose();
    dailyPagesReadController.dispose();
    mainIdeaController.dispose();
    yourThoughtsController.dispose();
    isBookTitleValid.dispose();
    isAuthorNameValid.dispose();
    isTotalPagesValid.dispose();
    isDailyPagesReadValid.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> myBooks = [];

  updateBooks() async {
    myBooks = (await FirebaseFirestore.instance
            .collection('books')
            .where("user", isEqualTo: currentUserId)
            .get())
        .docs;
    setState(() {});
  }

  findCurrentBook() async {
    final relatedBooks = await FirebaseFirestore.instance
        .collection('books')
        .where("user", isEqualTo: currentUserId)
        .get();
    if (relatedBooks.size > 0) {
      relatedBook = relatedBooks.docs.first;
      myBooks = relatedBooks.docs;
      bookImage = relatedBooks.docs.first.get("bookImage");

      bookTitleController.text = relatedBooks.docs.first.get("bookTitle");
      authorNameController.text = relatedBooks.docs.first.get("authorName");
      totalPagesController.text =
          relatedBooks.docs.first.get("totalPages").toString();
      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      final dailyPagesReads = await FirebaseFirestore.instance
          .collection('pageReads')
          .where("book", isEqualTo: relatedBooks.docs.first.id)
          .where("created", isGreaterThan: Timestamp.fromDate(today))
          .get();
      setState(() {
        totalPagesRead = relatedBooks.docs.first.get("totalPagesRead");
        totalDailyPagesRead = dailyPagesReads.docs
            .map((e) => int.parse(e.get("dailyPagesRead").toString()))
            .fold(0, (a, b) => a + b);
      });
    }
  }

  String bookImage = "";

  onBookSelected(String id) async {
    relatedBook =
        (await FirebaseFirestore.instance.collection('books').doc(id).get());
    bookTitleController.text = relatedBook!.get("bookTitle");
    authorNameController.text = relatedBook!.get("authorName");
    totalPagesController.text = relatedBook!.get("totalPages").toString();

    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final dailyPagesReads = await FirebaseFirestore.instance
        .collection('pageReads')
        .where("book", isEqualTo: id)
        .where("created", isGreaterThan: Timestamp.fromDate(today))
        .get();

    totalPagesRead = relatedBook!.get("totalPagesRead");
    bookImage = relatedBook!.get("bookImage") ?? "";
    dailyPagesRead = dailyPagesReads.docs
        .map((e) => int.parse(e.get("dailyPagesRead").toString()))
        .fold(0, (a, b) => a + b);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Okuma Girişi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kitaplarım',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownMenu(
                    dropdownMenuEntries: [
                      const DropdownMenuEntry(value: null, label: "Yeni kitap"),
                      ...myBooks.map((a) => DropdownMenuEntry(
                          value: a.id, label: a.data()["bookTitle"]))
                    ],
                    onSelected: (v) {
                      if (v == null) {
                        relatedBook = null;
                        bookTitleController.clear();
                        authorNameController.clear();
                        totalPagesController.clear();
                        bookImage = "";
                        dailyPagesRead = 0;
                        totalDailyPagesRead = 0;
                        totalPagesRead = 0;

                        setState(() {});
                      } else {
                        onBookSelected(v);
                      }
                    },
                    initialSelection: relatedBook?.id,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Okunan Kitap Bilgileri',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Kitap resmi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              if (bookImage.isNotEmpty)
                Image.network(
                  bookImage,
                  width: MediaQuery.of(context).size.width / 2,
                )
              else
                FilledButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      try {
                        final firebaseImage = await FirebaseStorage.instance
                            .ref(
                                "bookImage${DateTime.now().millisecondsSinceEpoch}")
                            .putFile(File(image.path));
                        bookImage = await firebaseImage.ref.getDownloadURL();
                        setState(() {});
                      } catch (e) {
                        EasyLoading.showError(
                            "Resim yüklenirken hata oluştu: ${e.toString()}");
                      }
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image),
                      Text("Seçiniz"),
                    ],
                  ),
                ),
              TextFormFieldWidget(
                hintText: 'Kitap Adı',
                controller: bookTitleController,
                isValid: isBookTitleValid,
              ),
              TextFormFieldWidget(
                hintText: 'Yazar Adı',
                controller: authorNameController,
                isValid: isAuthorNameValid,
              ),
              TextFormFieldWidget(
                minCharacters: 1,
                hintText: 'Toplam Sayfa Sayısı',
                controller: totalPagesController,
                isValid: isTotalPagesValid,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Text(
                'Günlük Okunan Sayfa Sayısı: $totalDailyPagesRead',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Toplam Okunan Sayfa Sayısı: $totalPagesRead',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormFieldWidget(
                      minCharacters: 1,
                      hintText: 'Okunan Sayfa Sayısı',
                      controller: dailyPagesReadController,
                      isValid: isDailyPagesReadValid,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isFormValid ? _saveData : null,
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
              if (relatedBook != null &&
                  totalPagesRead >=
                      (relatedBook!.data()
                          as Map<String, dynamic>)["totalPages"]) ...[
                const SizedBox(height: 20),
                const Text(
                  'Sorular',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormFieldWidget(
                  hintText: 'Ana Fikir',
                  controller: mainIdeaController,
                  isValid: ValueNotifier(false),
                ),
                TextFormFieldWidget(
                  hintText: 'Siz Olsaydınız',
                  controller: yourThoughtsController,
                  isValid: ValueNotifier(false),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        EasyLoading.show();

                        await relatedBook!.reference
                            .update({"recommended": true});
                        relatedBook = (await FirebaseFirestore.instance
                            .collection('books')
                            .doc(relatedBook!.id)
                            .get());
                        setState(() {});
                        EasyLoading.dismiss();
                      },
                      child: Text(relatedBook!.data()!["recommended"] ?? false
                          ? "Tavsiye Edildi"
                          : 'Tavsiye Et'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final mainIdea = mainIdeaController.text;
                        final yourThoughts = yourThoughtsController.text;

                        if (mainIdea.isEmpty) {
                          showToast("Lütfen ana fikir yazınız");
                          return;
                        }
                        if (yourThoughts.isEmpty) {
                          showToast(
                              "Lütfen sizin düşüncüleriniz alanını doldurun");
                          return;
                        }
                        try {
                          EasyLoading.show();
                          await relatedBook!.reference.update({
                            "yourThoughts": yourThoughts,
                            "mainIdea": mainIdea,
                          });

                          EasyLoading.dismiss();
                          EasyLoading.showSuccess("Kaydedildi");
                        } catch (e) {
                          EasyLoading.showError("Bir hata oluştu");
                          EasyLoading.dismiss();
                        }
                      },
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _saveData() async {
    final bookTitle = bookTitleController.text;
    final authorName = authorNameController.text;
    final totalPages = totalPagesController.text;
    final dailyPagesRead = dailyPagesReadController.text;

    if (dailyPagesRead.isEmpty || int.tryParse(dailyPagesRead) == 0) {
      showToast("Lütfen okunan sayfa sayısını giriniz");
      return;
    }
    if (bookTitle.isEmpty) {
      showToast("Lütfen kitap adını giriniz");
      return;
    }
    if (authorName.isEmpty) {
      showToast("Lütfen yazar adını giriniz");
      return;
    }
    if (totalPages.isEmpty || int.tryParse(totalPages) == 0) {
      showToast("Lütfen toplam sayfa sayısını giriniz");
      return;
    }

    EasyLoading.show();
    try {
      String relatedBookId = "";
      if (relatedBook == null) {
        final booksDoc = FirebaseFirestore.instance.collection('books').doc();
        relatedBookId = booksDoc.id;
        await booksDoc.set({
          "bookTitle": bookTitle,
          "authorName": authorName,
          "totalPages": int.parse(totalPages),
          "totalPagesRead": int.parse(dailyPagesRead),
          "user": currentUserId,
          "bookImage": bookImage,
          "recommended": false
        });

        totalPagesRead = int.parse(dailyPagesRead);
        updateBooks();
      } else {
        relatedBookId = relatedBook!.id;
        relatedBook!.reference.update({
          "totalPagesRead":
              relatedBook!.data()!["totalPagesRead"] + int.parse(dailyPagesRead)
        });
        setState(() {
          totalPagesRead = relatedBook!.data()!["totalPagesRead"] +
              int.parse(dailyPagesRead);
        });
      }

      await FirebaseFirestore.instance.collection('pageReads').doc().set({
        "book": relatedBookId,
        "dailyPagesRead": int.parse(dailyPagesRead),
        "created": Timestamp.now(),
        "user": currentUserId
      });
      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      final pageReads = await FirebaseFirestore.instance
          .collection('pageReads')
          .where("book", isEqualTo: relatedBookId)
          .where("created", isGreaterThan: Timestamp.fromDate(today))
          .get();

      totalDailyPagesRead = pageReads.docs
          .map((e) => int.parse(e.get("dailyPagesRead").toString()))
          .fold(0, (a, b) => a + b);

      setState(() {});
      EasyLoading.dismiss();
      EasyLoading.showSuccess("Kaydedildi");
    } catch (e) {
      EasyLoading.showError("Bir hata oluştu");
      EasyLoading.dismiss();
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid = isBookTitleValid.value &&
          isAuthorNameValid.value &&
          isTotalPagesValid.value &&
          isDailyPagesReadValid.value;
    });
  }
}
