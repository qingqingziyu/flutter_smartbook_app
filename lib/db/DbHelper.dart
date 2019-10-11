import 'dart:io';

import 'package:flutter_smartbook_app/bean/BookshelfBean.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

/**
 *@作者：陈飞
 *@说明：数据库工具类
 *@创建日期: 2019/8/19 10:26
 */
class DbHelper {
  final String _tableName = "Bookshelf";

  Database _db = null;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await _initDb();
    return _db;
  }

  /**
   *@作者：陈飞
   *@说明：初始化数据库
   *@创建日期: 2019/8/19 10:26
   */
  _initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "books.db");
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  /**
   *@作者：陈飞
   *@说明：创建书架表
   *@创建日期: 2019/8/19 10:41
   */
  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $_tableName("
        "id INTEGER PRIMARY KEY,"
        "title TEXT,"
        "image TEXT,"
        "readProgress TEXT,"
        "bookUrl TEXT,"
        "bookId TEXT,"
        "offset DOUBLE,"
        "isReversed INTEGER,"
        "chaptersIndex INTEGER)");
    print("Created tables");
  }

  /**
   *@作者：陈飞
   *@说明：添加书籍到书架
   *@创建日期: 2019/8/19 10:41
   */
  Future<int> addBookshelfItem(BookshelfBean item) async {
    print("addBookshelfItem = ${item.bookId}");
    var dbCliend = await db;
    int res = await dbCliend.insert("$_tableName", item.toMap());
    return res;
  }

  /**
   *@作者：陈飞
   *@说明：根据 id 查询判断书籍是否存在书架
   *@创建日期: 2019/8/19 10:47
   */
  Future<BookshelfBean> queryBooks(String bookId) async {
    var dbCliend = await db;
    var result = await dbCliend
        .query(_tableName, where: "bookId = ?", whereArgs: [bookId]);
    if (result != null && result.length > 0) {
      return BookshelfBean.fromMap(result[0]);
    }
    return null;
  }

  /**
   *@作者：陈飞
   *@说明：根据id移除书籍
   *@创建日期: 2019/8/19 10:49
   */
  Future<int> deleteBooks(String id) async {
    var dbClient = await db;
    var result =
        await dbClient.delete(_tableName, where: "bookId = ?", whereArgs: [id]);
    print("deleteItem = $result");
    return result;
  }

  /**
   *@作者：陈飞
   *@说明：查询加入书架的所有书籍
   *@创建日期: 2019/8/19 10:52
   */
  Future<List> getTotalList() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $_tableName");
    return result.toList();
  }

  /**
   *@作者：陈飞
   *@说明：更新书籍进度
   *@创建日期: 2019/8/19 10:53
   */
  Future<int> updateBooks(BookshelfBean user) async {
    var dbClient = await db;
    return await dbClient.update(_tableName, user.toMap(),
        where: "bookId = ?", whereArgs: [user.bookId]);
  }


  /**
   *@作者：陈飞
   *@说明：关闭
   *@创建日期: 2019/8/19 10:56
   */
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
