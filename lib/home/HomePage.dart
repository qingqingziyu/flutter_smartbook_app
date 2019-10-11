import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smartbook_app/book/BookshelfPage.dart';
import 'package:flutter_smartbook_app/book/MePage.dart';
import 'package:flutter_smartbook_app/book/TabHomePage.dart';
import 'package:flutter_smartbook_app/utils/colors.dart';
import 'package:flutter_smartbook_app/utils/dimens.dart';

class HomePage extends StatefulWidget {

  static  const platform = const MethodChannel("samples.flutter.io/permission");

  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  //列表图标
  final List<Image> _tabImage = [
    Image.asset(
      "images/icon_tab_bookshelf_n.png",
      width: Dimens.homeImageSize,
      height: Dimens.homeImageSize,
    ),
    Image.asset(
      "images/icon_tab_bookshelf_p.png",
      width: Dimens.homeImageSize,
      height: Dimens.homeImageSize,
    ),
    Image.asset(
      "images/icon_tab_home_n.png",
      width: Dimens.homeImageSize,
      height: Dimens.homeImageSize,
    ),
    Image.asset(
      "images/icon_tab_home_p.png",
      width: Dimens.homeImageSize,
      height: Dimens.homeImageSize,
    ),
    Image.asset(
      "images/icon_tab_me_n.png",
      width: Dimens.homeImageSize,
      height: Dimens.homeImageSize,
    ),
    Image.asset(
      "images/icon_tab_me_p.png",
      width: Dimens.homeImageSize,
      height: Dimens.homeImageSize,
    ),
  ];

  //标记
  int _tabIndex = 0;


  @override
  void initState() {
    super.initState();

    //申请权限
    _getPermission();
  }

  //与原生相互调用 requestCameraPermissions 是安卓原生方法，申请权限，在MainActivity里面
  void _getPermission() async{
    final String result = await HomePage.platform.invokeMethod('requestCameraPermissions');
    print("result = $result");
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: IndexedStack(
        children: <Widget>[BookshelfPage(), TabHomePage(), MePage()],
        index: _tabIndex,
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
              icon: _tabIndex == 0 ? _tabImage[1] : _tabImage[0],
              title: Text("书架")),
          BottomNavigationBarItem(
              icon: _tabIndex == 1 ? _tabImage[3] : _tabImage[2],
              title: Text("书城")),
          BottomNavigationBarItem(
              icon: _tabIndex == 2 ? _tabImage[5] : _tabImage[4],
              title: Text("我的")),
        ],
        currentIndex: _tabIndex,
        backgroundColor: MyColors.white,
        activeColor: MyColors.homeTabText,
        onTap: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
      ),
    );
  }
}
