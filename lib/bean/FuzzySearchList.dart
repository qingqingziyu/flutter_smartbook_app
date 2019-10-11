class FuzzySearchList{
  int wordCount;
  String id;
  String author;
  String cat;
  String cover;
  String title;


  FuzzySearchList(this.wordCount, this.id, this.author, this.cat, this.cover,
      this.title);

  FuzzySearchList.fromJson(jsonRes) {
    wordCount = jsonRes['wordCount'];
    id = jsonRes['_id'];
    author = jsonRes['author'];
    cat = jsonRes['cat'];
    cover = jsonRes['cover'];
    title = jsonRes['title'];
  }
}