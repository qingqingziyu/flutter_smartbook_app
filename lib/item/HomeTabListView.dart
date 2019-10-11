import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smartbook_app/bean/Books.dart';
import 'package:flutter_smartbook_app/bean/CategoriesReq.dart';
import 'package:flutter_smartbook_app/bean/CategoriesResp.dart';
import 'package:flutter_smartbook_app/book/BookInfoPage.dart';
import 'package:flutter_smartbook_app/http/Repository.dart';
import 'package:flutter_smartbook_app/utils/StringUtils.dart';
import 'package:flutter_smartbook_app/utils/colors.dart';
import 'package:flutter_smartbook_app/view/FailureView.dart';
import 'package:flutter_smartbook_app/view/LoadingView.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_smartbook_app/utils/dimens.dart';

/**
 *@作者：陈飞
 *@说明：书城 Item
 *@创建日期: 2019/8/19 15:03
 */
class HomeTabListView extends StatefulWidget {
  final String major;
  final String gender;

  HomeTabListView(this.gender, this.major);

  @override
  State<StatefulWidget> createState() {
    return _HomeTabListView();
  }
}

class _HomeTabListView extends State<HomeTabListView>
    with AutomaticKeepAliveClientMixin
    implements OnLoadReloadListener {
  List<Books> _list = [];

  LoadStatus _loadStatus = LoadStatus.LOADING;

  List<String> _listImage = [
    "images/icon_swiper_1.png",
    "images/icon_swiper_2.png",
    "images/icon_swiper_3.png",
    "images/icon_swiper_4.png",
    "images/icon_swiper_5.png",
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if(_loadStatus == LoadStatus.LOADING){
      return LoadingView();
    }
    if(_loadStatus == LoadStatus.FAILURE){
      return FailureView(this);
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        if (index == 0) {
          return _swiper();
        }
        return __buildListViewItem(index - 1);
      },
      itemCount: _list.length + 1,
    );
  }

  /**
   *@作者：陈飞
   *@说明：轮播栏
   *@创建日期: 2019/8/19 16:02
   */
  Widget _swiper() {
    return Container(
      height: 180,
      child: Swiper(
        itemCount: 5,
        itemBuilder: (context, index) {
          print("index=$index");
          return Container(
            margin: const EdgeInsets.only(top: 16, bottom: 10),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(_listImage[index]), fit: BoxFit.cover),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          );
        },
        autoplayDisableOnInteraction: true,
        itemHeight: 180,
        onTap: (index) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BookInfoPage("59ba0dbb017336e411085a4e", false);
          }));
        },
        viewportFraction: 0.9,
        scale: 0.93,
        outer: true,
        pagination: new SwiperPagination(
            alignment: Alignment.bottomCenter,
            builder: DotSwiperPaginationBuilder(
              activeColor: MyColors.textBlack6,
              color: MyColors.paginationColor,
              size: 5,
              activeSize: 5,
            )),
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：条目
   *@创建日期: 2019/8/19 16:02
   */
  Widget __buildListViewItem(int position) {
    var imageUrl = StringUtils.convertImageUrl(_list[position].cover);
    print("图片地址:" + imageUrl);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BookInfoPage(_list[position].id, false)));
      },
      child: Container(
        padding:
            EdgeInsets.fromLTRB(Dimens.leftMargin, 12, Dimens.rightMargin, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(
              imageUrl,
              height: 99,
              width: 77,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _list[position].title,
                  style: TextStyle(color: MyColors.textBlack3, fontSize: 16),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  _list[position].shortIntro,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: MyColors.textBlack6, fontSize: 14),
                ),
                SizedBox(
                  height: 9,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _list[position].author,
                        style:
                            TextStyle(color: MyColors.textBlack9, fontSize: 14),
                      ),
                    ),
                    _list[position].tags != null &&
                            _list[position].tags.length > 0
                        ? tagView(_list[position].tags[0])
                        : tagView("限免"),
                    _list[position].tags != null &&
                            _list[position].tags.length > 1
                        ? SizedBox(
                            width: 4,
                          )
                        : SizedBox(),
                    _list[position].tags != null &&
                            _list[position].tags.length > 1
                        ? tagView(_list[position].tags[1])
                        : SizedBox(),
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  /**
   *@作者：陈飞
   *@说明：标签分类
   *@创建日期: 2019/8/20 15:53
   */
  Widget tagView(String tag) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      alignment: Alignment.center,
      child: Text(
        tag,
        style: TextStyle(color: MyColors.textBlack9, fontSize: 11.5),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          border: Border.all(width: 0.5, color: MyColors.textBlack9)),
    );
  }

  void getData() async {
    print('----------------' + this.widget.gender);
    print('----------------' + this.widget.major);

    CategoriesReq categoriesReq = new CategoriesReq();
    categoriesReq.gender = this.widget.gender;
    categoriesReq.major = this.widget.major;
    categoriesReq.type = "hot";
    categoriesReq.start = 0;
    categoriesReq.limit = 40;

    await Repository().getCategories(categoriesReq.toJson()).then((map) {
      var categoriesResp = CategoriesResp.fromJson(map);
      print("打印结果" + map.toString());
      setState(() {
        _loadStatus = LoadStatus.SUCCESS;
        _list = categoriesResp.books;
      });
    }).catchError((e) {
      setState(() {
        _loadStatus = LoadStatus.FAILURE;
      });
      print("解析报错:" + e.toString());
    });
  }

  @override
  void onReload() {
    setState(() {
      _loadStatus = LoadStatus.LOADING;
    });

    getData();
  }

  @override
  bool get wantKeepAlive => true;
}
