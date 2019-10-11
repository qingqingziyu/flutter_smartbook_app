import 'package:flutter/material.dart';
import 'package:flutter_smartbook_app/utils/colors.dart';

/**
 *@作者：陈飞
 *@说明：加载进度条
 *@创建日期: 2019/8/20 16:13
 */
class LoadingView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoadingView();
  }
}

class _LoadingView extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  List<String> _imageList = [
    "images/icon_load_1.png",
    "images/icon_load_2.png",
    "images/icon_load_3.png",
    "images/icon_load_4.png",
    "images/icon_load_5.png",
    "images/icon_load_6.png",
    "images/icon_load_7.png",
    "images/icon_load_8.png",
    "images/icon_load_9.png",
    "images/icon_load_10.png",
    "images/icon_load_11.png",
  ];

  Animation<int> _animatable;
  AnimationController _animatedContainer;
  int _position = 0;

  @override
  void initState() {
    super.initState();
    _animatedContainer =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    _animatable = IntTween(begin: 0, end: 10).animate(_animatedContainer)
      ..addListener(() {
        if (_position != _animatable.value) {
          setState(() {
            _position = _animatable.value;
          });
        }
      });

    _animatable.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animatedContainer.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animatedContainer.forward();
      }
    });
    _animatedContainer.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: MyColors.homeGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            _imageList[_position],
            width: 43,
            height: 43,
            gaplessPlayback: true,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animatedContainer.dispose();
    super.dispose();
  }
}

abstract class OnLoadReloadListener {
  void onReload();
}

enum LoadStatus {
  LOADING,
  SUCCESS,
  FAILURE,
}
