import 'dart:convert';

import 'FuzzySearchList.dart';

class FuzzySearchResp{
  int total;
  bool ok;
  List<FuzzySearchList> books;

  factory FuzzySearchResp(jsonStr) => jsonStr == null ? null : jsonStr is String ? new FuzzySearchResp.fromJson(json.decode(jsonStr)) : new FuzzySearchResp.fromJson(jsonStr);

  FuzzySearchResp.fromJson(jsonRes) {
    total = jsonRes['total'];
    ok = jsonRes['ok'];
    books = jsonRes['books'] == null ? null : [];

    for (var booksItem in books == null ? [] : jsonRes['books']){
      books.add(booksItem == null ? null : new FuzzySearchList.fromJson(booksItem));
    }
  }
}
