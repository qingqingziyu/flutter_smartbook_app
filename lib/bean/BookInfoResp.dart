class BookInfoResp {
  int banned;
  int buytype;
  int chaptersCount;
  int currency;
  int followerCount;
  int latelyFollower;
  int postCount;
  int safelevel;
  int serializeWordCount;
  int sizetype;
  int wordCount;
  bool gg;
  bool le;
  bool advertRead;
  bool allowBeanVoucher;
  bool allowFree;
  bool allowMonthly;
  bool allowVoucher;
  bool donate;
  bool hasCopyright;
  bool hasCp;
  bool isAllowNetSearch;
  bool isFineBook;
  bool isForbidForFreeApp;
  bool isSerial;
  bool limit;
  String id;
  String author;
  String authorDesc;
  String cat;
  String contentType;
  String copyrightDesc;
  String cover;
  String creater;
  String lastChapter;
  String longIntro;
  String majorCate;
  String majorCateV2;
  String minorCate;
  String minorCateV2;
  String originalAuthor;
  String retentionRatioX;
  String superscript;
  String title;
  String updated;
  List<dynamic> anchors;
  List<String> gender;
  List<String> tags;
  RatingBean rating;

  BookInfoResp(
      this.banned,
      this.buytype,
      this.chaptersCount,
      this.currency,
      this.followerCount,
      this.latelyFollower,
      this.postCount,
      this.safelevel,
      this.serializeWordCount,
      this.sizetype,
      this.wordCount,
      this.gg,
      this.le,
      this.advertRead,
      this.allowBeanVoucher,
      this.allowFree,
      this.allowMonthly,
      this.allowVoucher,
      this.donate,
      this.hasCopyright,
      this.hasCp,
      this.isAllowNetSearch,
      this.isFineBook,
      this.isForbidForFreeApp,
      this.isSerial,
      this.limit,
      this.id,
      this.author,
      this.authorDesc,
      this.cat,
      this.contentType,
      this.copyrightDesc,
      this.cover,
      this.creater,
      this.lastChapter,
      this.longIntro,
      this.majorCate,
      this.majorCateV2,
      this.minorCate,
      this.minorCateV2,
      this.originalAuthor,
      this.retentionRatioX,
      this.superscript,
      this.title,
      this.updated,
      this.anchors,
      this.gender,
      this.tags,
      this.rating);

  BookInfoResp.fromJson(Map<String, dynamic> jsonRes) {
    banned = jsonRes['banned'];
    buytype = jsonRes['buytype'];
    chaptersCount = jsonRes['chaptersCount'];
    currency = jsonRes['currency'];
    followerCount = jsonRes['followerCount'];
    latelyFollower = jsonRes['latelyFollower'];
    postCount = jsonRes['postCount'];
    safelevel = jsonRes['safelevel'];
    serializeWordCount = jsonRes['serializeWordCount'];
    sizetype = jsonRes['sizetype'];
    wordCount = jsonRes['wordCount'];
    gg = jsonRes['_gg'];
    le = jsonRes['_le'];
    advertRead = jsonRes['advertRead'];
    allowBeanVoucher = jsonRes['allowBeanVoucher'];
    allowFree = jsonRes['allowFree'];
    allowMonthly = jsonRes['allowMonthly'];
    allowVoucher = jsonRes['allowVoucher'];
    donate = jsonRes['donate'];
    hasCopyright = jsonRes['hasCopyright'];
    hasCp = jsonRes['hasCp'];
    isAllowNetSearch = jsonRes['isAllowNetSearch'];
    isFineBook = jsonRes['isFineBook'];
    isForbidForFreeApp = jsonRes['isForbidForFreeApp'];
    isSerial = jsonRes['isSerial'];
    limit = jsonRes['limit'];
    id = jsonRes['_id'];
    author = jsonRes['author'];
    authorDesc = jsonRes['authorDesc'];
    cat = jsonRes['cat'];
    contentType = jsonRes['contentType'];
    copyrightDesc = jsonRes['copyrightDesc'];
    cover = jsonRes['cover'];
    creater = jsonRes['creater'];
    lastChapter = jsonRes['lastChapter'];
    longIntro = jsonRes['longIntro'];
    majorCate = jsonRes['majorCate'];
    majorCateV2 = jsonRes['majorCateV2'];
    minorCate = jsonRes['minorCate'];
    minorCateV2 = jsonRes['minorCateV2'];
    originalAuthor = jsonRes['originalAuthor'];
    retentionRatioX = jsonRes['retentionRatioX'];
    superscript = jsonRes['superscript'];
    title = jsonRes['title'];
    updated = jsonRes['updated'];
    anchors = jsonRes['anchors'] == null ? null : [];

    for (var anchorsItem in anchors == null ? [] : jsonRes['anchors']) {
      anchors.add(anchorsItem);
    }

    gender = jsonRes['gender'] == null ? null : [];

    for (var genderItem in gender == null ? [] : jsonRes['gender']) {
      gender.add(genderItem);
    }

    tags = jsonRes['tags'] == null ? null : [];

    for (var tagsItem in tags == null ? [] : jsonRes['tags']) {
      tags.add(tagsItem);
    }

    rating = jsonRes['rating'] == null
        ? null
        : new RatingBean.fromJson(jsonRes['rating']);
  }
}

class RatingBean {
  int count;
  double score;
  bool isEffect;

  RatingBean(this.count, this.score, this.isEffect);

  RatingBean.fromJson(jsonRes) {
    count = jsonRes['count'];
    score = jsonRes['score'];
    isEffect = jsonRes['isEffect'];
  }
}
