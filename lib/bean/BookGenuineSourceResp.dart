
import 'dart:convert';

class BookGenuineSourceResp{

  List<BookGenuineSourceList> data;


  factory BookGenuineSourceResp(jsonStr) => jsonStr == null ? null : jsonStr is String ? new BookGenuineSourceResp.fromJson(json.decode(jsonStr)) : new BookGenuineSourceResp.fromJson(jsonStr);


  BookGenuineSourceResp.fromJson(jsonRes) {
    data = jsonRes['data'] == null ? null : [];

    for (var dataItem in data == null ? [] : jsonRes['data']){
      data.add(dataItem == null ? null : new BookGenuineSourceList.fromJson(dataItem));
    }
  }
}

class BookGenuineSourceList{
  int chaptersCount;
  bool isCharge;
  bool starting;
  String id;
  String host;
  String lastChapter;
  String link;
  String name;
  String source;
  String updated;


  BookGenuineSourceList(this.chaptersCount, this.isCharge, this.starting,
      this.id, this.host, this.lastChapter, this.link, this.name, this.source,
      this.updated);

  BookGenuineSourceList.fromJson(jsonRes) {
    chaptersCount = jsonRes['chaptersCount'];
    isCharge = jsonRes['isCharge'];
    starting = jsonRes['starting'];
    id = jsonRes['_id'];
    host = jsonRes['host'];
    lastChapter = jsonRes['lastChapter'];
    link = jsonRes['link'];
    name = jsonRes['name'];
    source = jsonRes['source'];
    updated = jsonRes['updated'];
  }
}