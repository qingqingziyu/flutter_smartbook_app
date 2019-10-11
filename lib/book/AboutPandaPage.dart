import 'package:flutter/material.dart';
import 'package:flutter_smartbook_app/home/HomePage.dart';
import 'package:flutter_smartbook_app/utils/dimens.dart';

/**
 *@作者：陈飞
 *@说明：关于
 *@创建日期: 2019/8/22 14:25
 */
class AboutPandaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutPandaPage();
  }
}

class _AboutPandaPage extends State<AboutPandaPage> {
  final url = 'https://github.com/q805699513/flutter_books';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        title: Text(""),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(Dimens.leftMargin, 20, Dimens.rightMargin, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "作者：四维",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "github：",
                    style: TextStyle(fontSize: 18),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Text(
                        url,
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      onTap: (){
                        _launchURL();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text("本项归四维所有",style: TextStyle(fontSize: 18),),
            ],
          ),
        ),
      ),
    );
  }

  /// 原生代码调用系统浏览器显示网页，url 为要打开的链接值传递
  Future<Null> _launchURL() async {
    print("launchURL start");
    final String result = await HomePage.platform.invokeMethod(
      'launchURL',
      <String, dynamic>{
        'url': url,
      },
    );
    print("launchURL=$result");
  }
}
