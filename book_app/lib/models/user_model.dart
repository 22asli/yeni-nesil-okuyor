class UserModel {
  final String name;
  final int totalPageCount;
  final List<String> booksRead;
  final List<String> recommendedBooks;

  UserModel({required this.name, required this.totalPageCount, required this.booksRead, required this.recommendedBooks});
}