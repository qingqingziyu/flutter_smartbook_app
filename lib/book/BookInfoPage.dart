import 'dart:async';

import "package:flutter/material.dart";
import 'package:flutter_smartbook_app/bean/BookInfoResp.dart';
import 'package:flutter_smartbook_app/bean/BookshelfBean.dart';
import 'package:flutter_smartbook_app/book/BookContentPage.dart';
import 'package:flutter_smartbook_app/db/DbHelper.dart';
import 'package:flutter_smartbook_app/event_bus/EventBus.dart';
import 'package:flutter_smartbook_app/http/Repository.dart';
import 'package:flutter_smartbook_app/utils/StringUtils.dart';
import 'package:flutter_smartbook_app/utils/colors.dart';
import 'package:flutter_smartbook_app/view/FailureView.dart';
import 'package:flutter_smartbook_app/view/LoadingView.dart';
import 'package:flutter_smartbook_app/utils/dimens.dart';
import 'package:flutter_smartbook_app/view/StaticRatingBar.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'BookChaptersPage.dart';

class BookInfoPage extends StatefulWidget {
  final String _bookId;
  final bool _back;

  BookInfoPage(this._bookId, this._back);

  @override
  State<StatefulWidget> createState() {
    return _BookInfoPage();
  }
}

class _BookInfoPage extends State<BookInfoPage>
    implements OnLoadReloadListener {
  LoadStatus _loadStatus = LoadStatus.LOADING;

  BookInfoResp _bookInfoResp;

  ScrollController _controller = ScrollController();

  /**
   *@作者：陈飞
   *@说明：颜色值
   *@创建日期: 2019/8/20 16:40
   */
  Color _iconColor = Color.fromARGB(255, 255, 255, 255);
  Color _titleBgColor = Color.fromARGB(0, 255, 255, 255);
  Color _titleTextColor = Color.fromARGB(0, 0, 0, 0);

  bool _isDividerGone = true;
  String _image;
  String _bookName;

  /**
   *@作者：陈飞
   *@说明：数据库
   *@创建日期: 2019/8/20 16:43
   */
  var _dbHelper = DbHelper();

  //判断是否加入书架
  bool _isAddBookshelf = false;
  BookshelfBean _bookshelfBean;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = eventBus.on<BooksEvent>().listen((event) {
      getDbData();
    });
    //请求数据
    getData();

    _controller.addListener(() {
      print(_controller.offset);
      //170
      if (_controller.offset <= 170) {
        setState(() {
          double num = (1 - _controller.offset / 170) * 255;
          //图标颜色
          _iconColor =
              Color.fromARGB(255, num.toInt(), num.toInt(), num.toInt());
          //标题背景颜色
          _titleBgColor = Color.fromARGB(255 - num.toInt(), 255, 255, 255);
          if (_controller.offset > 90) {
            _titleTextColor = Color.fromARGB(255 - num.toInt(), 0, 0, 0);
          } else {
            _titleTextColor = Color.fromARGB(0, 0, 0, 0);
          }
          if (_controller.offset > 160) {
            _isDividerGone = false;
          } else {
            _isDividerGone = true;
          }
        });
      } else {
        setState(() {
          _isDividerGone = false;
          _iconColor = Color.fromARGB(255, 0, 0, 0);
          _titleTextColor = Color.fromARGB(255, 0, 0, 0);
          _titleBgColor = Color.fromARGB(255, 255, 255, 255);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(child: ChildLayout()),
    );
  }

  /**
   *@作者：陈飞
   *@说明：查询数据库
   *@创建日期: 2019/8/20 16:47
   */
  void getDbData() async {
    var list = await _dbHelper.queryBooks(_bookInfoResp.id);
    if (list != null) {
      print("getDbData1");
      _bookshelfBean = list;
      setState(() {
        _isAddBookshelf = true;
      });
    } else {
      print("getDbData2");
      setState(() {
        _isAddBookshelf = false;
      });
    }
  }

  /**
   *@作者：陈飞
   *@说明：请求数据
   *@创建日期: 2019/8/20 16:53
   */
  void getData() async {
    await Repository().getBookInfo(this.widget._bookId).then((json) {
      print("getData1");
      setState(() {
        _loadStatus = LoadStatus.SUCCESS;
        _bookInfoResp = BookInfoResp.fromJson(json);
        _image = _bookInfoResp.cover;
        _bookName = _bookInfoResp.title;
      });
      /**
       *@作者：陈飞
       *@说明：查找数据库
       *@创建日期: 2019/8/20 16:58
       */
      getDbData();
    }).catchError((e) {
      print("解析报错:${e.toString()}");
      setState(() {
        _loadStatus = LoadStatus.FAILURE;
      });
    });
  }

  /**
   *@作者：陈飞
   *@说明：显示视图
   *@创建日期: 2019/8/20 17:14
   */
  Widget ChildLayout() {
    if (_loadStatus == LoadStatus.LOADING) {
      return LoadingView();
    }
    if (_loadStatus == LoadStatus.FAILURE) {
      return FailureView(this);
    }

    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        //内容
        contentView(),
        titleView(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: MaterialButton(
            onPressed: () {
              if (this.widget._back) {
                Navigator.pop(context);
                return;
              }
              if (_isAddBookshelf) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BookContentPage(
                      _bookshelfBean.bookUrl,
                      this.widget._bookId,
                      _image,
                      _bookshelfBean.chaptersIndex,
                      _bookshelfBean.isReversed == 1,
                      _bookName,
                      _bookshelfBean.offset);
                }));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BookContentPage(null, this.widget._bookId, _image, 0,
                      false, _bookName, 0);
                }));
              }
            },
            height: Dimens.titleHeight,
            color: MyColors.textPrimaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0))),
            child: Text(
              _isAddBookshelf
                  ? (_bookshelfBean.readProgress == "0" ? "开始阅读" : "继续阅读")
                  : "开始阅读",
              style: TextStyle(color: MyColors.white, fontSize: 16),
            ),
          ),
        )
      ],
    );
  }

  /**
   *@作者：陈飞
   *@说明：  内容视图
   *@创建日期: 2019/8/20 17:15
   */
  Widget contentView() {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          coverView(),
          bodyView(),
          Container(
            height: 14,
            color: MyColors.dividerColor,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                Dimens.leftMargin, 20, Dimens.rightMargin, 20),
            child: Text(
              _bookInfoResp.longIntro,
              style:
                  TextStyle(fontSize: Dimens.textSizeM, color: MyColors.black),
            ),
          ),
          Container(
            height: 14,
            color: MyColors.dividerColor,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                Dimens.leftMargin, 12, Dimens.rightMargin, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "最新书评",
                  style: TextStyle(
                      fontSize: Dimens.textSizeM, color: MyColors.textBlack3),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(1, 1, 3, 0),
                  child: Image.asset(
                    "images/icon_info_edit.png",
                    width: 16,
                    height: 16,
                  ),
                ),
                Text(
                  "写书评",
                  style: TextStyle(
                    fontSize: Dimens.textSizeL,
                    color: Color(0xFF33C3A5),
                  ),
                ),
              ],
            ),
          ),
          commentList(),
          Container(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Text(
              "查看更多的评论(268)",
              style: TextStyle(
                  color: MyColors.textPrimaryColor, fontSize: Dimens.textSizeL),
            ),
          ),
          Container(
            alignment: Alignment.center,
            color: MyColors.dividerColor,
            padding: EdgeInsets.fromLTRB(0, 14, 0, 68),
            child: Text(
              "" + _bookInfoResp.copyrightDesc,
              style: TextStyle(color: MyColors.textBlack9, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：封面头视图
   *@创建日期: 2019/8/20 17:18
   */
  Widget coverView() {
    return Container(
      color: MyColors.infoBgColor,
      padding:
          EdgeInsets.fromLTRB(Dimens.leftMargin, 68, Dimens.rightMargin, 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(
            StringUtils.convertImageUrl(_bookInfoResp.cover),
            height: 137,
            width: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 14,
          ),
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _bookInfoResp.title,
                maxLines: 1,
                style: TextStyle(
                    fontSize: Dimens.titleTextSize, color: MyColors.white),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _bookInfoResp.author,
                style: TextStyle(
                    fontSize: Dimens.textSizeM, color: MyColors.white),
              ),
              SizedBox(
                height: 61,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _bookInfoResp.cat,
                    style: TextStyle(
                        fontSize: Dimens.textSizeL, color: MyColors.white),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(11, 0, 11, 0),
                    color: Color(0x50FFFFFF),
                    width: 1,
                    height: 12,
                    child: Container(),
                  ),
                  Text(
                    getWordCount(_bookInfoResp.wordCount),
                    style: TextStyle(
                        fontSize: Dimens.textSizeL, color: MyColors.white),
                  ),
                  Expanded(child: Container()),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 3, 4),
                    child: Text(
                      _bookInfoResp.rating != null
                          ? _bookInfoResp.rating.score.toStringAsFixed(1)
                          : "7.0",
                      style: TextStyle(
                          fontSize: 23, color: MyColors.fractionColor),
                    ),
                  ),
                  Text(
                    "分",
                    style: TextStyle(
                        fontSize: Dimens.textSizeL, color: MyColors.white),
                  )
                ],
              )
            ],
          ))
        ],
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：封面体视图
   *@创建日期: 2019/8/21 9:23
   */
  Widget bodyView() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        bodyChildView(
            _isAddBookshelf
                ? 'images/icon_details_bookshelf_add.png'
                : 'images/icon_details_bookshelf.png',
            _isAddBookshelf ? "已在书架" : "加入书架",
            0),
        bodyChildView("images/icon_details_chapter.png",
            _bookInfoResp.chaptersCount.toString() + "章", 1),
        bodyChildView("images/icon_details_reward.png", "支持作品", 2),
        bodyChildView("images/icon_details_download.png", "批量下载", 3),
      ],
    );
  }

  /**
   *@作者：陈飞
   *@说明：封面体子视图
   *@创建日期: 2019/8/21 9:25
   */
  Widget bodyChildView(String image, String content, int tap) {
    return Expanded(
        child: new GestureDetector(
      onTap: () {
        if (tap == 0) {
          //判断是否加入书架
          if (!_isAddBookshelf) {
            var bean = BookshelfBean(
                _bookName, _image, "0", "", this.widget._bookId, 0, 0, 0);
            _dbHelper.addBookshelfItem(bean);
            setState(() {
              _isAddBookshelf = true;
            });
            eventBus.fire(new BooksEvent());
          }
        }
        if (tap == 1) {
          //章节目录
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            print("章节页前");
            return BookChaptersPage(this.widget._bookId, _image, _bookName);
          }));
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              image,
              width: 34,
              height: 34,
              fit: BoxFit.contain,
            ),
            Text(
              content,
              style: TextStyle(
                  color: MyColors.textBlack3, fontSize: Dimens.textSizeM),
            ),
          ],
        ),
      ),
    ));
  }

  /**
   *@作者：陈飞
   *@说明：刷新
   *@创建日期: 2019/8/21 9:57
   */
  @override
  void onReload() {
    setState(() {
      _loadStatus = LoadStatus.LOADING;
    });
    getData();
  }

  /**
   *@作者：陈飞
   *@说明：销毁生命周期
   *@创建日期: 2019/8/21 9:57
   */
  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  /**
   *@作者：陈飞
   *@说明：字数格式化
   *@创建日期: 2019/8/21 9:18
   */
  String getWordCount(int wordCount) {
    if (wordCount > 10000) {
      return (wordCount / 10000).toStringAsFixed(1) + "万字";
    }
    return wordCount.toString() + "字";
  }

  /**
   *@作者：陈飞
   *@说明：评论内容视图
   *@创建日期: 2019/8/21 9:57
   */
  Widget commentList() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Dimens.leftMargin, 0, Dimens.rightMargin, 0),
      child: Column(
        children: <Widget>[
          itemView("嘻嘻", "求更新，不够看", 4.5, "9", true),
          itemView("书友805699513", "不错不错。", 5, "8", false),
          itemView("书友007", "没看先点赞", 5, "5", true),
          itemView("书友00888", "好文章不错，就是更新太慢了。", 3, "1", false),
          itemView("书友00666", "打卡", 5, "9", true),
        ],
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：评论条目视图
   *@创建日期: 2019/8/21 9:58
   */
  Widget itemView(
      String name, String content, double rate, String likeNum, bool image) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            ClipOval(
              child: SizedBox(
                width: 32,
                height: 32,
                child: Image.asset("images/icon_default_avatar.png"),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(
                        color: MyColors.textBlack6, fontSize: Dimens.textSizeL),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: StaticRatingBar(
                      size: 10,
                      rate: rate,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 14, 0, 14),
          child: Text(
            content,
            style: TextStyle(fontSize: 12, color: MyColors.textBlack9),
          ),
        ),
        Row(
          children: <Widget>[
            Text(
              "2019.05.09",
              style: TextStyle(color: MyColors.textBlack9, fontSize: 12),
            ),
            Expanded(
              child: Container(),
            ),
            GestureDetector(
              child: image
                  ? Image.asset(
                      "images/icon_like_true.png",
                      width: 18,
                      height: 18,
                    )
                  : Image.asset(
                      "images/icon_like_false.png",
                      width: 18,
                      height: 18,
                    ),
              onTap: () {
                Fluttertoast.showToast(msg: "本app不允许点赞", fontSize: 14.0);
              },
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(2, 0, 20, 0),
              child: Text(
                likeNum,
                style: TextStyle(color: MyColors.textBlack9, fontSize: 12),
              ),
            ),
            Image.asset(
              "images/icon_comment.png",
              width: 18,
              height: 18,
            )
          ],
        ),
        SizedBox(
          height: 18,
        )
      ],
    );
  }

  /**
   *@作者：陈飞
   *@说明：标题视图
   *@创建日期: 2019/8/21 10:53
   */
  Widget titleView() {
    return Container(
      color: _titleBgColor,
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
                    "images/icon_title_back.png",
                    color: _iconColor,
                    width: 20,
                    height: Dimens.titleHeight,
                  ),
                ),
              ),
            ),
          ),
          Text(
            _bookInfoResp.title,
            style: TextStyle(
              fontSize: Dimens.titleTextSize,
              color: _titleTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Positioned(
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      Dimens.leftMargin, 0, Dimens.rightMargin, 0),
                  child: Image.asset(
                    "images/icon_share.png",
                    color: _iconColor,
                    width: 18,
                    height: Dimens.titleHeight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Offstage(
                offstage: _isDividerGone,
                child: Divider(
                  height: 1,
                  color: MyColors.dividerDarkColor,
                ),
              ))
        ],
      ),
    );
  }
}
