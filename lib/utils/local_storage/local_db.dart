List<Map<String, dynamic>> queryResultToMapList(List<Map> queryResult) {
  List<Map<String, dynamic>> _list = [];

  for (var item in queryResult) {
    Map<String, dynamic> _temp = {};
    for (var i = 0; i < item.keys.length; i++) {
    
      _temp[item.keys.toList()[i]] = item.values.toList()[i];
    }
    _list.add(_temp);
  }

  return _list;
}

Map<String, dynamic> queryResultToMap(Map queryResult) {
  Map<String, dynamic> _temp = {};

  for (var i = 0; i < queryResult.keys.length; i++) {
    _temp[queryResult.keys.toList()[i]] = queryResult.values.toList()[i];
  }

  return _temp;
}
