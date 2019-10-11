import 'package:flutter_smartbook_app/bean/BookChaptersReq.dart';

import 'DioUtils.dart';

/**
 *@作者：陈飞
 *@说明：网络请求
 *@创建日期: 2019/8/19 16:20
 */
class Repository {
  /**
   *@作者：陈飞
   *@说明： 获取首页列表
   *@创建日期: 2019/8/19 16:56
   */
  Future<Map> getCategories(queryParameters) async {
    return await DioUtils()
        .request("/book/by-categories", queryParameters: queryParameters);
  }

  /**
   *@作者：陈飞
   *@说明：获取小说详情
   *@创建日期: 2019/8/20 16:55
   */
  Future<Map> getBookInfo(bookId) async {
    return await DioUtils().request("/book/$bookId");
  }

  /**
   *@作者：陈飞
   *@说明：获取正版源
   *@创建日期: 2019/8/21 13:39
   */
  Future<Map> getBookGenuineSource(queryParameters) async {
    return await DioUtils().request("/btoc", queryParameters: queryParameters);
  }

  /**
   *@作者：陈飞
   *@说明：获取小说章节列表
   *@创建日期: 2019/8/21 13:47
   */
  Future<Map> getBookChapters(bookId) async {
    return await DioUtils().request(
      "/atoc/$bookId",
      queryParameters: BookChaptersReq("chapters").toJson(),
    );
  }

  /**
   *@作者：陈飞
   *@说明：获取小说某个章节内容
   *@创建日期: 2019/8/21 15:13
   */
  Future<Map> getBookChaptersContent(url) async {
    return await DioUtils().request(
      "http://chapterup.zhuishushenqi.com/chapter/$url",
    );
  }

  /**
   *@作者：陈飞
   *@说明：搜索
   *@创建日期: 2019/8/22 15:22
   */
  Future<Map> getFuzzySearchBookList(queryParameters) async {
    return await DioUtils()
        .request("/book/fuzzy-search", queryParameters: queryParameters);
  }
}
