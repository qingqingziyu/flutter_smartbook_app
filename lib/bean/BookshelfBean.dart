class BookshelfBean {
  /// 书名
  String title;
  String image;
  String readProgress;
  String bookUrl;
  String bookId;
  double offset;

  /// 1是倒序
  int isReversed;
  int chaptersIndex;

  BookshelfBean(this.title, this.image, this.readProgress, this.bookUrl,
      this.bookId, this.offset, this.isReversed, this.chaptersIndex);

  BookshelfBean.fromMap(Map<String,dynamic> map){
    title = map["title"] as String;
    image = map["image"] as String;
    readProgress = map["readProgress"] as String;
    bookUrl = map["bookUrl"] as String;
    bookId = map["bookId"] as String;
    offset = map["offset"] as double;
    isReversed = map["isReversed"] as int;
    chaptersIndex = map["chaptersIndex"] as int;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "title": title,
      "image": image,
      "readProgress": readProgress,
      "bookUrl": bookUrl,
      "bookId": bookId,
      "offset": offset,
      "isReversed": isReversed,
      "chaptersIndex": chaptersIndex,
    };
    return map;
  }
}
