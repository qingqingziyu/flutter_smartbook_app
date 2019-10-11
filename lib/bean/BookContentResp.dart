
import 'dart:convert';

class BookContentResp{
  bool ok;
  BookChapterContent chapter;


  factory BookContentResp(jsonStr) => jsonStr == null ? null : jsonStr is String ? new BookContentResp.fromJson(json.decode(jsonStr)) : new BookContentResp.fromJson(jsonStr);

  BookContentResp.fromJson(jsonRes) {
    ok = jsonRes['ok'];
    chapter = jsonRes['chapter'] == null ? null : new BookChapterContent.fromJson(jsonRes['chapter']);
  }

}

class BookChapterContent{
  int currency;
  bool isVip;
  String body;
  String cpContent;
  String id;
  String title;

  BookChapterContent.fromParams({this.currency, this.isVip, this.body, this.cpContent, this.id, this.title});

  BookChapterContent.fromJson(jsonRes) {
    currency = jsonRes['currency'];
    isVip = jsonRes['isVip'];
    body = jsonRes['body'];
    cpContent = jsonRes['cpContent'];
    id = jsonRes['id'];
    title = jsonRes['title'];
  }
}