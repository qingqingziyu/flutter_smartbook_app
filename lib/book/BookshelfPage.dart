import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smartbook_app/bean/BookshelfBean.dart';
import 'package:flutter_smartbook_app/db/DbHelper.dart';
import 'package:flutter_smartbook_app/item/BookshelfItem.dart';
import 'package:flutter_smartbook_app/utils/StringUtils.dart';
import 'package:flutter_smartbook_app/utils/colors.dart';
import 'package:flutter_smartbook_app/utils/dimens.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_smartbook_app/event_bus/EventBus.dart';

import 'BookSearchPage.dart';

/**
 * 书架
 */
class BookshelfPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookshelfPage();
  }
}

class _BookshelfPage extends State {
  List<BookshelfBean> _listBean = [];

  StreamSubscription booksSubscription;

  final String _emptyTitle = "添加书籍";

  /**
   *@作者：陈飞
   *@说明：数据库
   *@创建日期: 2019/8/19 10:56
   */
  var _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    booksSubscription = eventBus.on<BooksEvent>().listen((event) {
      print("");
      getDbData();
    });
    getDbData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          _titleView(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(
                        Dimens.leftMargin, 0, Dimens.rightMargin, 20),
                    padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                    decoration: BoxDecoration(
                        color: Color(0XFFEBF9F6),
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    child: Text(
                      "【Panda看书】全网小说不限时免费观看",
                      style: TextStyle(
                          color: MyColors.textBlack6,
                          fontSize: Dimens.textSizeL),
                    ),
                  ),
                  GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, childAspectRatio: 0.5),
                      itemCount: _listBean.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      itemBuilder: (context, index) {
                        return itemView(index);
                      })
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  /**
   * 标题
   */
  _titleView() {
    return Container(
      color: MyColors.primary,
      constraints: BoxConstraints.expand(height: Dimens.titleHeight),
      padding: EdgeInsets.fromLTRB(Dimens.leftMargin, 0, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "书架",
            style: TextStyle(
                fontSize: Dimens.titleTextSize, color: MyColors.textBlack3),
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(flex: 1, child: Container()),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_){
                  return BookSearchPage();
                }));
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    Dimens.leftMargin, 0, Dimens.rightMargin, 0),
                child: Image.asset(
                  'images/icon_bookshelf_search.png',
                  width: 20,
                  height: Dimens.titleHeight,
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Image.asset(
                  'images/icon_bookshelf_more.png',
                  width: 3.5,
                  height: Dimens.titleHeight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：从数据库查找
   *@创建日期: 2019/8/22 15:01
   */
  void getDbData() async {
    await _dbHelper.getTotalList().then((list) {
      _listBean.clear();
      list.reversed.forEach((item) {
        BookshelfBean todoItem = BookshelfBean.fromMap(item);
        setState(() {
          _listBean.add(todoItem);
        });
      });
      setAddItem();
    }).catchError((e) {});
  }

  /**
   *@作者：陈飞
   *@说明：添加样式
   *@创建日期: 2019/8/19 14:02
   */
  void setAddItem() {
    BookshelfBean todoItem =
        BookshelfBean(_emptyTitle, null, "", "", "", 0, 0, 0);
    setState(() {
      _listBean.add(todoItem);
    });
  }

  @override
  void dispose() {
    super.dispose();
    booksSubscription.cancel();
    _dbHelper.close();
  }

  /**
   *@作者：陈飞
   *@说明：显示条目
   *@创建日期: 2019/8/22 14:58
   */
  Widget itemView(int index) {
    //阅读进度
    String readProgress = _listBean[index].readProgress;
    if (readProgress == "0") {
      readProgress = "未读";
    } else {
      readProgress = "已读$readProgress%";
    }

    //判断是否加入书架
    bool addBookSheelfItem = false;
    if (_listBean[index].title == _emptyTitle) {
      addBookSheelfItem = true;
      readProgress = "";
    }
    //按条目顺序切换显示方向
    var position = index == 0 ? 0 : index % 3;
    var axisAlignment;
    if (position == 0) {
      axisAlignment = CrossAxisAlignment.start;
    } else if (position == 1) {
      axisAlignment = CrossAxisAlignment.center;
    } else if (position == 2) {
      axisAlignment = CrossAxisAlignment.end;
    }
    return Column(
      crossAxisAlignment: axisAlignment,
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            child: addBookSheelfItem
                ? Image.asset(
              //当前条目是空的，那么显示添加图片
              "images/icon_bookshelf_empty_add.png",
              height: 121,
              width: 92,
              fit: BoxFit.cover,
            )
                : Image.network(
              StringUtils.convertImageUrl(_listBean[position].image),
              height: 121,
              width: 92,
              fit: BoxFit.cover,
            ),
            onLongPress: () {
              if (!addBookSheelfItem) {
                showDeleteDialog(context, position);
              }
            },
            onTap: (){
              if(addBookSheelfItem){
//                Navigator.push(context, MaterialPageRoute(builder: (context){
//                  return Boo
//                }));
              }
            },
          ),
        ),
        SizedBox(height: 10,)
      ],
    );
  }

  /**
   *@作者：陈飞
   *@说明：显示是否删除的对话框
   *@创建日期: 2019/8/15 11:08
   */
  showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text("删除书籍"),
          content: Text("删除此书后，书籍源文件及阅读进度也将被删除"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                //退出
                Navigator.of(context).pop();
                _dbHelper.deleteBooks(_listBean[index].bookId).then((i) {
                  setState(() {
                    _listBean.removeAt(index);
                  });
                });
              },
              child: Text("确定"),
            ),
            FlatButton(
              onPressed: () {
                //退出
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
          ],
        );
      },
    );
  }
}
