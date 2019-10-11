import 'package:flutter/material.dart';
import 'package:flutter_smartbook_app/utils/colors.dart';

import 'LoadingView.dart';

/**
 *@作者：陈飞
 *@说明：加载失败进度条
 *@创建日期: 2019/8/20 16:15
 */
class FailureView extends StatefulWidget {
  OnLoadReloadListener _onLoadReloadListener;

  FailureView(this._onLoadReloadListener);

  @override
  State<StatefulWidget> createState() {
    return _FailureView();
  }
}

class _FailureView extends State<FailureView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.homeGrey,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "images/icon_network_error.png",
            width: 150,
            height: 150,
          ),
          SizedBox(
            height: 14,
          ),
          Text(
            "咦？没网络啦~检查下设置吧",
            style: TextStyle(fontSize: 12, color: MyColors.textBlack9),
          ),
          SizedBox(
            height: 25,
          ),
          MaterialButton(
            onPressed: (){

            },
            minWidth: 150,
            height: 43,
            color: MyColors.textPrimaryColor,
            child: Text(
              "重新加载",
              style: TextStyle(
                color: MyColors.white,
                fontSize: 16
              ),
            ),
          )
        ],
      ),
    );
  }
}
