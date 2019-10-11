import 'package:flutter/material.dart';

class BookChaptersBean {
  int currency;
  int order;
  int partsize;
  int time;
  int totalpage;
  bool isVip;
  bool unreadble;
  String chapterCover;
  String id;
  String link;
  String title;

  BookChaptersBean(
      this.currency,
      this.order,
      this.partsize,
      this.time,
      this.totalpage,
      this.isVip,
      this.unreadble,
      this.chapterCover,
      this.id,
      this.link,
      this.title);

  BookChaptersBean.fromJson(Map<String, dynamic> jsonRes) {
    currency = jsonRes['currency'];
    order = jsonRes['order'];
    partsize = jsonRes['partsize'];
    time = jsonRes['time'];
    totalpage = jsonRes['totalpage'];
    isVip = jsonRes['isVip'];
    unreadble = jsonRes['unreadble'];
    chapterCover = jsonRes['chapterCover'];
    id = jsonRes['id'];
    link = jsonRes['link'];
    title = jsonRes['title'];
  }
}
