import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smartbook_app/bean/BookChaptersBean.dart';
import 'package:flutter_smartbook_app/bean/BookChaptersResp..dart';
import 'package:flutter_smartbook_app/bean/BookContentResp.dart';
import 'package:flutter_smartbook_app/bean/BookGenuineSourceResp.dart';
import 'package:flutter_smartbook_app/bean/BookshelfBean.dart';
import 'package:flutter_smartbook_app/bean/GenuineSourceReq.dart';
import 'package:flutter_smartbook_app/book/BookInfoPage.dart';
import 'package:flutter_smartbook_app/db/DbHelper.dart';
import 'package:flutter_smartbook_app/event_bus/EventBus.dart';
import 'package:flutter_smartbook_app/http/Repository.dart';
import 'package:flutter_smartbook_app/utils/colors.dart';
import 'package:flutter_smartbook_app/view/FailureView.dart';
import 'package:flutter_smartbook_app/view/LoadingView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_smartbook_app/utils/dimens.dart';
import 'package:fluttertoast/fluttertoast.dart';

/**
 *@作者：陈飞
 *@说明：内容页
 *@创建日期: 2019/8/21 11:12
 */
class BookContentPage extends StatefulWidget {
  /// 书籍章节内容 url
  String _bookUrl;

  /// 书籍 id
  String _bookId;

  /// 书籍图片
  String _bookImage;

  /// 保存到数据库里的书名
  String _bookName;

  /// 目录选择的 item 索引
  int _index = 0;

  /// 初次进页面 scrollview 滑动到上一次阅读的地方
  double _initOffset = 0;

  /// 章节是否倒序
  bool _isReversed;

  BookContentPage(this._bookUrl, this._bookId, this._bookImage, this._index,
      this._isReversed, this._bookName, this._initOffset);

  @override
  State<StatefulWidget> createState() {
    return _BookContentPage();
  }
}

class _BookContentPage extends State<BookContentPage>
    implements OnLoadReloadListener {
  var _dbHelper = DbHelper();

  static final double _addBookshelfWidth = 95;
  static final double _bottomHeight = 300;
  static final double _sImagePadding = 20;

  LoadStatus _loadStatus = LoadStatus.LOADING;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String _content = "";
  double _height = 0;
  double _bottomPadding = _bottomHeight;
  double _imagePadding = _sImagePadding;
  double _addBookshelfPadding = _addBookshelfWidth;
  int _duration = 200;
  double _spaceValue = 1.8;
  double _textSizeValue = 18;
  bool _isNighttime = false;
  bool _isAddBookshelf = false;
  List<BookChaptersBean> _listBean = [];
  String _title = "";
  double _offset = 0;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _offset = this.widget._initOffset;
    _spGetTextSizeValue().then((value) {
      setState(() {
        _textSizeValue = value;
      });
    });
    _spGetSpaceValue().then((value) {
      setState(() {
        _spaceValue = value;
      });
    });
    getChaptersListData();
    setStemStyle();
    isAddBookShelf().then((isAdd) {
      setState(() {
        _isAddBookshelf = isAdd;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _isNighttime ? Colors.black : Colors.white,
      drawer: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).padding.top,
              color: Colors.black,
            ),
            Container(
              height: 50,
              color: MyColors.homeGrey,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    this.widget._isReversed = !this.widget._isReversed;
                    this.widget._index =
                        _listBean.length - 1 - this.widget._index;
                    _listBean = _listBean.reversed.toList();
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ),
            Expanded(
                child: ListView.separated(
              itemCount: _listBean.length,
              itemBuilder: (context, index) {
                return itemView(index);
              },
              separatorBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(Dimens.leftMargin, 0, 0, 0),
                  child: Divider(height: 1, color: MyColors.dividerDarkColor),
                );
              },
            ))
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                _bottomPadding == 0
                    ? _bottomPadding = _bottomHeight
                    : _bottomPadding = 0;
                _height == Dimens.titleHeight
                    ? _height = 0
                    : _height = Dimens.titleHeight;
                _imagePadding == 0
                    ? _imagePadding = _sImagePadding
                    : _imagePadding = 0;
                _addBookshelfPadding == 0
                    ? _addBookshelfPadding = _addBookshelfWidth
                    : _addBookshelfPadding = 0;
              });
            },
            child: _loadStatus == LoadStatus.LOADING
                ? LoadingView()
                : _loadStatus == LoadStatus.FAILURE
                    ? FailureView(this)
                    : SingleChildScrollView(
                        controller: _controller,
                        padding: EdgeInsets.fromLTRB(
                            16, 16 + MediaQuery.of(context).padding.top, 9, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _title,
                              style: TextStyle(
                                fontSize: _textSizeValue + 2,
                                color: Color(0xFF9F8C54),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              _content,
                              style: TextStyle(
                                  color: _isNighttime
                                      ? MyColors.contentColor
                                      : MyColors.black,
                                  fontSize: _textSizeValue,
                                  height: _spaceValue),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                MaterialButton(
                                  onPressed: () {
                                    if (this.widget._isReversed) {
                                      if (this.widget._index >=
                                          _listBean.length - 1) {
                                        Fluttertoast.showToast(
                                            msg: "没有上一章了", fontSize: 14.0);
                                      } else {
                                        setState(() {
                                          _loadStatus = LoadStatus.LOADING;
                                        });
                                        this.widget._initOffset = 0;
                                        ++this.widget._index;
                                        this.widget._bookUrl =
                                            _listBean[this.widget._index].link;
                                        getData();
                                      }
                                    } else {
                                      if (this.widget._index == 0) {
                                        Fluttertoast.showToast(
                                            msg: "没有上一章了", fontSize: 14.0);
                                      } else {
                                        setState(() {
                                          _loadStatus = LoadStatus.LOADING;
                                        });
                                        this.widget._initOffset = 0;
                                        --this.widget._index;
                                        this.widget._bookUrl =
                                            _listBean[this.widget._index].link;
                                        getData();
                                      }
                                    }
                                  },
                                  minWidth: 125,
                                  textColor: MyColors.textPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(125),
                                    ),
                                    side: BorderSide(
                                        color: MyColors.textPrimaryColor,
                                        width: 1),
                                  ),
                                  child: Text("上一章"),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    if (!this.widget._isReversed) {
                                      if (this.widget._index >=
                                          _listBean.length - 1) {
                                        Fluttertoast.showToast(
                                            msg: "没有下一章了", fontSize: 14.0);
                                      } else {
                                        setState(() {
                                          _loadStatus = LoadStatus.LOADING;
                                        });
                                        this.widget._initOffset = 0;
                                        ++this.widget._index;
                                        this.widget._bookUrl =
                                            _listBean[this.widget._index].link;
                                        getData();
                                      }
                                    } else {
                                      if (this.widget._index == 0) {
                                        Fluttertoast.showToast(
                                            msg: "没有下一章了", fontSize: 14.0);
                                      } else {
                                        setState(() {
                                          _loadStatus = LoadStatus.LOADING;
                                        });
                                        this.widget._initOffset = 0;
                                        ++this.widget._index;
                                        this.widget._bookUrl =
                                            _listBean[this.widget._index].link;
                                        getData();
                                      }
                                    }
                                  },
                                  minWidth: 125,
                                  textColor: MyColors.textPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(125),
                                    ),
                                    side: BorderSide(
                                        color: MyColors.textPrimaryColor,
                                        width: 1),
                                  ),
                                  child: Text("下一章"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
          ),
          settingView(),
          //加入
          _isAddBookshelf
              ? Container()
              : Positioned(
                  top: 78,
                  right: 0,
                  child: Container(
                    width: _addBookshelfWidth,
                    child: AnimatedPadding(
                      padding:
                          EdgeInsets.fromLTRB(_addBookshelfPadding, 30, 0, 0),
                      duration: Duration(milliseconds: _duration),
                      child: GestureDetector(
                        onTap: () {
                          Fluttertoast.showToast(msg: "加入书架成功", fontSize: 14.0);
                          addBookshelf();
                          setState(() {
                            _isAddBookshelf = true;
                          });
                        },
                        child: Container(
                          width: _addBookshelfWidth,
                          padding: EdgeInsets.fromLTRB(10, 7, 0, 7),
                          decoration: BoxDecoration(
                            color: MyColors.contentBgColor,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(50),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                "images/icon_add_bookshelf.png",
                                height: 20,
                                width: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "加入书架",
                                style: TextStyle(
                                  color: MyColors.contentColor,
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：显示条目视图
   *@创建日期: 2019/8/21 16:50
   */
  Widget itemView(int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _loadStatus = LoadStatus.LOADING;
            this.widget._index = index;
            this.widget._bookUrl = _listBean[index].link;
            getData();
          });
          Navigator.pop(context);
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
                      fontSize: Dimens.textSizeM,
                      color: this.widget._index == index
                          ? MyColors.textPrimaryColor
                          : MyColors.textBlack9),
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

  /**
   *@作者：陈飞
   *@说明：设置视图
   *@创建日期: 2019/8/21 17:31
   */
  Widget settingView() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).padding.top,
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: _duration),
          height: _height,
          child: Container(
            height: Dimens.titleHeight,
            color: MyColors.contentBgColor,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          Dimens.leftMargin, 0, Dimens.rightMargin, 0),
                      child: Image.asset(
                        "images/icon_title_back.png",
                        width: 20,
                        height: Dimens.titleHeight,
                        color: MyColors.contentColor,
                      ),
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return BookInfoPage(this.widget._bookId, true);
                      }));
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Image.asset(
                        "images/icon_bookshelf_more.png",
                        width: 3.0,
                        height: Dimens.titleHeight,
                        color: MyColors.contentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: SizedBox()),
        Container(
          margin: EdgeInsets.fromLTRB(Dimens.leftMargin, 0, 0, 0),
          width: _sImagePadding * 2,
          height: _sImagePadding * 2,
          child: AnimatedPadding(
            padding: EdgeInsets.fromLTRB(
                _imagePadding, _imagePadding, _imagePadding, _imagePadding),
            duration: Duration(milliseconds: _duration),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isNighttime = !_isNighttime;
                });
              },
              child: Image.asset(
                _isNighttime
                    ? "images/icon_content_daytime.png"
                    : "images/icon_content_nighttime.png",
                height: 36,
                width: 36,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          height: _bottomHeight,
          child: AnimatedPadding(
            padding: EdgeInsets.fromLTRB(0, _bottomPadding, 0, 0),
            duration: Duration(milliseconds: _duration),
            child: Container(
              height: _bottomHeight,
              padding: EdgeInsets.fromLTRB(
                  Dimens.leftMargin, 20, Dimens.rightMargin, Dimens.leftMargin),
              color: MyColors.contentBgColor,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "字号",
                        style: TextStyle(
                            color: MyColors.contentColor,
                            fontSize: Dimens.textSizeM),
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      Image.asset(
                        "images/icon_content_font_small.png",
                        color: MyColors.white,
                        width: 28,
                        height: 18,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorColor: MyColors.textPrimaryColor,
                            inactiveTrackColor: MyColors.white,
                            activeTrackColor: MyColors.textPrimaryColor,
                            activeTickMarkColor: Colors.transparent,
                            inactiveTickMarkColor: Colors.transparent,
                            trackHeight: 2.5,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: _textSizeValue,
                            label: "字号:$_textSizeValue",
                            divisions: 20,
                            min: 10,
                            max: 30,
                            onChanged: (double value) {
                              setState(() {
                                _textSizeValue = value;
                              });
                            },
                            onChangeEnd: (values) {
                              _spSetTextSizeValue(values);
                            },
                          ),
                        ),
                      ),
                      Image.asset(
                        "images/icon_content_font_big.png",
                        color: MyColors.white,
                        width: 28,
                        height: 18,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "间隙",
                        style: TextStyle(
                          color: MyColors.contentColor,
                          fontSize: Dimens.textSizeM,
                        ),
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      Image.asset(
                        "images/icon_content_space_big.png",
                        color: MyColors.white,
                        width: 28,
                        height: 18,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              valueIndicatorColor: MyColors.textPrimaryColor,
                              inactiveTrackColor: MyColors.white,
                              activeTrackColor: MyColors.textPrimaryColor,
                              activeTickMarkColor: Colors.transparent,
                              inactiveTickMarkColor: Colors.transparent,
                              trackHeight: 2.5,
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 8)),
                          child: Slider(
                            value: _spaceValue,
                            label: "字间距:$_spaceValue",
                            min: 1.0,
                            divisions: 20,
                            max: 3.0,
                            onChanged: (double values) {
                              setState(() {
                                _spaceValue = values;
                              });
                            },
                            onChangeEnd: (value) {
                              _spSetSpaceValue(value);
                            },
                          ),
                        ),
                      ),
                      Image.asset(
                        "images/icon_content_space_small.png",
                        color: MyColors.white,
                        width: 28,
                        height: 18,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          print("openDrawer");
                          closeSettingView();
                          _scaffoldKey.currentState.openDrawer();
                        },
                        child: Image.asset(
                          "images/icon_content_catalog.png",
                          height: 50,
                        ),
                      ),
                      Image.asset(
                        "images/icon_content_setting.png",
                        height: 50,
                      ),
                      Image.asset(
                        "images/icon_content_brightness.png",
                        height: 50,
                      ),
                      Image.asset(
                        "images/icon_content_read.png",
                        height: 50,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  /**
   *@作者：陈飞
   *@说明：判断是否加入
   *@创建日期: 2019/8/21 16:02
   */
  Future<bool> isAddBookShelf() async {
    var bookList = await _dbHelper.queryBooks(this.widget._bookId);
    if (bookList != null) {
      return true;
    } else {
      return false;
    }
  }

  /**
   *@作者：陈飞
   *@说明：设置状态栏文字颜色
   *@创建日期: 2019/8/21 15:31
   */
  void setStemStyle() async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    });
  }

  _spSetSpaceValue(double value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setDouble("spaceValue", value);
  }

  _spSetTextSizeValue(double values) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble("textSizeValue", values);
  }

  Future<double> _spGetTextSizeValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var value = sharedPreferences.getDouble("textSizeValue");
    return value ?? 18;
  }

  Future<double> _spGetSpaceValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var values = sharedPreferences.getDouble("spaceValue");
    return values ?? 1.3;
  }

  /**
   *@作者：陈飞
   *@说明：获取列表
   *@创建日期: 2019/8/21 14:59
   */
  void getChaptersListData() async {
    GenuineSourceReq genuineSourceReq =
        GenuineSourceReq("summary", this.widget._bookId);
    var entryPoint =
        await Repository().getBookGenuineSource(genuineSourceReq.toJson());
    BookGenuineSourceResp bookGenuineSourceResp =
        BookGenuineSourceResp(entryPoint);
    if (bookGenuineSourceResp != null &&
        bookGenuineSourceResp.data.length > 0) {
      await Repository()
          .getBookChapters(bookGenuineSourceResp.data[0].id)
          .then((json) {
        BookChaptersResp bookChaptersResp = BookChaptersResp(json);
        setState(() {
          _listBean = bookChaptersResp.chapters;
          if (this.widget._isReversed) {
            _listBean = _listBean.reversed.toList();
          }
        });
        if (this.widget._bookUrl == null || this.widget._bookUrl.length == 0) {
          this.widget._bookUrl = _listBean[0].link;
        }
        getData();
      }).catchError((e) {
        print("解析报错:${e.toString()}");
      });
    }
  }

  /**
   *@作者：陈飞
   *@说明：获取内容
   *@创建日期: 2019/8/21 15:08
   */
  void getData() async {
    _controller = new ScrollController(
        initialScrollOffset: this.widget._initOffset, keepScrollOffset: false);
    _controller.addListener(() {
      print("offeset");
      _offset = _controller.offset;
    });
    await Repository()
        .getBookChaptersContent(this.widget._bookUrl)
        .then((json) {
      BookContentResp bookChaptersResp = new BookContentResp(json);
      setState(() {
        _loadStatus = LoadStatus.SUCCESS;
        //部分排版有问题，需要特殊处理
        _content = bookChaptersResp.chapter.cpContent
            .replaceAll("\t", "\n")
            .replaceAll("\n\n\n\n", "\n\n");
        _title = bookChaptersResp.chapter.title;
        if (bookChaptersResp.chapter.isVip) {
          showVipDialog();
        }
      });
    }).catchError((e) {
      print("e=${e.toString()}");
      setState(() {
        _loadStatus = LoadStatus.FAILURE;
        _title = "";
      });
    });
  }

  /**
   *@作者：陈飞
   *@说明：显示对话框
   *@创建日期: 2019/8/21 15:19
   */
  void showVipDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
              title: Text("该章节为 Vip 章节，请联系作者"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("确定"))
              ]);
        });
  }

  @override
  void onReload() {
    _loadStatus = LoadStatus.LOADING;
    getData();
  }

  /**
   *@作者：陈飞
   *@说明：隐藏view
   *@创建日期: 2019/8/22 10:35
   */
  void closeSettingView() {
    setState(() {
      _bottomPadding = _bottomHeight;
      _height = 0;
      _imagePadding = _sImagePadding;
      _addBookshelfPadding = _addBookshelfWidth;
    });
  }

  /**
   *@作者：陈飞
   *@说明：添加
   *@创建日期: 2019/8/22 10:52
   */
  void addBookshelf() {
    double index = (this.widget._index * 100 / _listBean.length);
    if (this.widget._isReversed) {
      index = 100 - index;
    }
    if (index < 0.1) {
      index = 0.1;
    }
    var bookshelfBean = BookshelfBean(
        this.widget._bookName,
        this.widget._bookImage,
        index.toStringAsFixed(1),
        this.widget._bookUrl,
        this.widget._bookId,
        _offset,
        this.widget._isReversed ? 1 : 0,
        this.widget._index);
    if (_isAddBookshelf) {
      _dbHelper.updateBooks(bookshelfBean).then((i) {});
    } else {
      _dbHelper.addBookshelfItem(bookshelfBean);
    }
    eventBus.fire(new BooksEvent());
  }

  @override
  void deactivate() {
    super.deactivate();
    isAddBookShelf().then((isAdd) {
      _isAddBookshelf = true;
      addBookshelf();
    });
  }
}
