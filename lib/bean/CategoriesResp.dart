import 'Books.dart';

class CategoriesResp {
  List<Books> books;

  bool ok;

  int total;

  CategoriesResp(this.books, this.ok, this.total);

  CategoriesResp.fromJson(Map<String, dynamic> json) {
    if (json['books'] != null) {
      books = new List();
      json['books'].forEach((e) {
        books.add(Books.fromJson(e));
      });
    }
    this.ok = json['ok'];
    this.total = json['total'];
  }
}
