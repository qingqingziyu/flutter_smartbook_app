
class CategoriesReq{
  String gender;
  String type;
  String major;
  int start;
  int limit;

  Map<String,dynamic> toJson(){
    return{
      'gender': gender,
      'type': type,
      'major': major,
      'start': start,
      'limit': limit,
    };
  }
}