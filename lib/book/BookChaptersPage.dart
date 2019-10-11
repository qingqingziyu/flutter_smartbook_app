import 'package:flutter/material.dart';
import 'package:flutter_smartbook_app/bean/BookChaptersBean.dart';
import 'package:flutter_smartbook_app/bean/BookChaptersResp..dart';
import 'package:flutter_smartbook_app/bean/BookGenuineSourceResp.dart';
import 'package:flutter_smartbook_app/bean/GenuineSourceReq.dart';
import 'package:flutter_smartbook_app/http/Repository.dart';
import 'package:flutter_smartbook_app/utils/colors.dart';
import 'package:flutter_smartbook_app/utils/dimens.dart';

import 'BookContentPage.dart';

/**
 *@作者：陈飞
 *@说明：章节页
 *@创建日期: 2019/8/21 9:35
 */
class BookChaptersPage extends StatefulWidget {
  final String _bookId;
  final String _image;
  final String _bookName;

  BookChaptersPage(this._bookId, this._image, this._bookName);

  @override
  State<StatefulWidget> createState() {
    return _BookChaptersPage();
  }
}

class _BookChaptersPage extends State<BookChaptersPage> {
  List<BookChaptersBean> _listBean = [];

  bool _isReversed = false;

  @override
  void initState() {
    super.initState();
    print("章节页");
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: titleView(),
      ),
      body: ListView.separated(
        itemCount: _listBean.length,
        itemBuilder: (context, index) {
          return itemView(index);
        },
        separatorBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(Dimens.leftMargin, 0, 0, 0),
            child: Divider(
              height: 1,
              color: MyColors.dividerDarkColor,
            ),
          );
        },
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：请求数据
   *@创建日期: 2019/8/21 13:35
   */
  void getData() async {
    GenuineSourceReq gestureDetector =
        GenuineSourceReq("summary", this.widget._bookId);
    var entryPoint =
        await Repository().getBookGenuineSource(gestureDetector.toJson());
    BookGenuineSourceResp bookGenuineSourceResp =
        BookGenuineSourceResp(entryPoint);

    if (bookGenuineSourceResp != null &&
        bookGenuineSourceResp.data.length > 0) {
      await Repository()
          .getBookChapters(bookGenuineSourceResp.data[0].id)
          .then((json) {
        print("当前的json：" + json.toString());
        BookChaptersResp bookChaptersResp = BookChaptersResp(json);
        setState(() {
          _listBean = bookChaptersResp.chapters;
        });
      }).catchError((e) {
        print("解析报错1:${e.toString()}");
      });
    }
  }

  /**
   *@作者：陈飞
   *@说明：头部视图
   *@创建日期: 2019/8/21 13:54
   */
  Widget titleView() {
    return Container(
      constraints: BoxConstraints.expand(height: Dimens.titleHeight),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      Dimens.leftMargin, 0, Dimens.rightMargin, 0),
                  child: Image.asset(
                    'images/icon_title_back.png',
                    width: 20,
                    height: Dimens.titleHeight,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_listBean != null && _listBean.length > 0) {
                setState(() {
                  _isReversed = !_isReversed;
                  _listBean = _listBean.reversed.toList();
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "目录",
                  style: TextStyle(
                      fontSize: Dimens.titleTextSize,
                      color: MyColors.textPrimaryColor),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  width: 4,
                ),
                Image.asset(
                  "images/icon_chapters_turn.png",
                  width: 15,
                  height: 15,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：条目 视图
   *@创建日期: 2019/8/21 14:13
   */
  Widget itemView(index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          //跳转到内容
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return BookContentPage(
                _listBean[index].link,
                this.widget._bookId,
                this.widget._image,
                index,
                _isReversed,
                this.widget._bookName,
                0);
          }));
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              Dimens.leftMargin, 16, Dimens.rightMargin, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                child: Text(
                  "${index + 1}. ",
                  style: TextStyle(fontSize: 9, color: MyColors.textBlack9),
                ),
              ),
              Expanded(
                child: Text(
                  _listBean[index].title,
                  style: TextStyle(
                      fontSize: Dimens.textSizeM, color: MyColors.textBlack9),
                ),
              ),
              _listBean[index].isVip
                  ? Image.asset(
                      "images/icon_chapters_vip.png",
                      width: 16,
                      height: 16,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
