import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

/**
 *@作者：陈飞
 *@说明：网络请求工具类
 *@创建日期: 2019/8/19 16:25
 */
class DioUtils {
  static final DioUtils _singleton = DioUtils._init();

  static Dio _dio;

  /**
   *@作者：陈飞
   *@说明：是否是debug模式
   *@创建日期: 2019/8/19 16:26
   */
  static bool _isDebug = true;

  /**
   *@作者：陈飞
   *@说明：打开debug模式
   *@创建日期: 2019/8/19 16:27
   */
  static void oepnDebug() {
    _isDebug = true;
  }

  DioUtils._init() {
    BaseOptions options = new BaseOptions(
      baseUrl: "http://api.zhuishushenqi.com",
      connectTimeout: 1000 * 10,
      receiveTimeout: 1000 * 20,
    );
    _dio = Dio(options);
    //日志
    _dio.interceptors.add(LogInterceptor(
        responseBody: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        request: true));
  }

  factory DioUtils() {
    return _singleton;
  }

  Future<Map> request<T>(String path,
      {String method = Method.get,
      queryParameters,
      Options options,
      CancelToken cancelToken}) async {
    Response response = await _dio.request(path,
        queryParameters: queryParameters,
        options: _checkOptions(method, options),
        cancelToken: cancelToken);
    _printHttpLog(response);
    if (response.statusCode == 200) {
      try {
        if (response.data is Map) {
          if (response.data["ok"] != null &&
              !response.data["ok"] &&
              response.data["msg"] != null &&
              response.data["code"] != null) {
            Fluttertoast.showToast(msg: response.data["msg"], fontSize: 14.0);
            return new Future.error(new DioError(
              response: response,
              message: response.data["msg"],
              type: DioErrorType.RESPONSE,
            ));
          }
          print("输出Map："+response.data.toString());
          return response.data;
        } else {
          if (response.data is List) {
            Map<String, dynamic> _dataMap = Map();
            _dataMap["data"] = response.data;
            print("输出List："+response.data.toString());
            return _dataMap;
          }
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "该网络不可用，清扫后重试", fontSize: 14.0);
        return Future.error(new DioError(
          response: response,
          message: "data parsing exception...",
          type: DioErrorType.RESPONSE,
        ));
      }
    }
    Fluttertoast.showToast(msg: "网络连接不可用，请稍后重试", fontSize: 14.0);

    return Future.error(DioError(
      response: response,
      message: "statusCode: ${response.statusCode}, service error",
      type: DioErrorType.RESPONSE,
    ));
  }

  Options _checkOptions(String method, Options options) {
    if (options == null) {
      options = new Options();
    }
    options.method = method;
    return options;
  }

  void _printHttpLog(Response response) {
    if (!_isDebug) {
      return;
    }

    try {
      print("----------------Http Log Start----------------" +
          "\n[statusCode]:   " +
          response.statusCode.toString() +
          "\n[request   ]:   " +
          _getOptionsStr(response.request));
      _printDataStr("reqdata ", response.request.data);
      _printDataStr("queryParameters ", response.request.queryParameters);
      _printDataStr("response", response.data);
      print("----------------Http Log Stop----------------");
    } catch (ex) {
      print("Http Log" + " error......");
    }
  }

  /// get Options Str.
  String _getOptionsStr(RequestOptions request) {
    return "method: " +
        request.method +
        "  baseUrl: " +
        request.baseUrl +
        "  path: " +
        request.path;
  }

  /// print Data Str.
  void _printDataStr(String tag, Object value) {
    String da = value.toString();
    while (da.isNotEmpty) {
      if (da.length > 512) {
        print("[$tag  ]:   " + da.substring(0, 512));
        da = da.substring(512, da.length);
      } else {
        print("[$tag  ]:   " + da);
        da = "";
      }
    }
  }
}

/**
 *@作者：陈飞
 *@说明：返回方法
 *@创建日期: 2019/8/19 16:54
 */
abstract class DioCallback<T> {
  void onSuccess(T t);

  void onError(DioError error);
}

/**
 *@作者：陈飞
 *@说明：请求方法
 *@创建日期: 2019/8/19 16:31
 */
class Method {
  static const String get = "GET";
  static final String post = "POST";
  static final String head = "HEAD";
  static final String delete = "DELETE";
  static final String patch = "PATCH";
}
