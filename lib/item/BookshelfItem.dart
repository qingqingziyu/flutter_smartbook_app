import 'package:flutter/material.dart';
import 'package:flutter_smartbook_app/bean/BookshelfBean.dart';
import 'package:flutter_smartbook_app/db/DbHelper.dart';
import 'package:flutter_smartbook_app/utils/StringUtils.dart';

/**
 *@作者：陈飞
 *@说明：条目
 *@创建日期: 2019/8/15 10:42
 */
class BookshelfItem extends StatefulWidget {
  List<BookshelfBean> listBean = [];
  int position = 0;

  BookshelfItem({this.listBean, this.position});

  @override
  State<StatefulWidget> createState() {
    return _BookshelfItem();
  }
}

class _BookshelfItem extends State<BookshelfItem> {
  final String _emptyTitle = "添加书籍";

  /**
   *@作者：陈飞
   *@说明：数据库
   *@创建日期: 2019/8/19 10:56
   */
  var _dbHelper = DbHelper();

  List<BookshelfBean> _listBean = [];

  int position = 0;

  @override
  void initState() {
    super.initState();
    _listBean = widget.listBean;
    position = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    //阅读进度
    String readProgress = _listBean[position].readProgress;
    if (readProgress == "0") {
      readProgress = "未读";
    } else {
      readProgress = "已读$readProgress%";
    }

    //判断是否加入书架
    bool addBookSheelfItem = false;
    if (_listBean[position].title == _emptyTitle) {
      addBookSheelfItem = true;
      readProgress = "";
    }
    //按条目顺序切换显示方向
    position = position == 0 ? 0 : position % 3;
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
