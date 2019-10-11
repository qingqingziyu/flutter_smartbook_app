
import 'dart:convert';

import 'BookChaptersBean.dart';

class BookChaptersResp{
  String id;
  String book;
  String host;
  String link;
  String name;
  String source;
  String updated;
  List<BookChaptersBean> chapters;

  factory BookChaptersResp(jsonStr) => jsonStr == null ? null : jsonStr is String ? new BookChaptersResp.fromJson(json.decode(jsonStr)) : new BookChaptersResp.fromJson(jsonStr);


  BookChaptersResp.fromJson(jsonRes) {
    id = jsonRes['_id'];
    book = jsonRes['book'];
    host = jsonRes['host'];
    link = jsonRes['link'];
    name = jsonRes['name'];
    source = jsonRes['source'];
    updated = jsonRes['updated'];
    chapters = jsonRes['chapters'] == null ? null : [];

    for (var chaptersItem in chapters == null ? [] : jsonRes['chapters']){
      chapters.add(chaptersItem == null ? null : new BookChaptersBean.fromJson(chaptersItem));
    }
  }
}

//class BookChaptersBean{
//  int currency;
//  int order;
//  int partsize;
//  int time;
//  int totalpage;
//  bool isVip;
//  bool unreadble;
//  String chapterCover;
//  String id;
//  String link;
//  String title;
//
//  BookChaptersBean.fromJson(jsonRes) {
//    currency = jsonRes['currency'];
//    order = jsonRes['order'];
//    partsize = jsonRes['partsize'];
//    time = jsonRes['time'];
//    totalpage = jsonRes['totalpage'];
//    isVip = jsonRes['isVip'];
//    unreadble = jsonRes['unreadble'];
//    chapterCover = jsonRes['chapterCover'];
//    id = jsonRes['id'];
//    link = jsonRes['link'];
//    title = jsonRes['title'];
//  }
//}