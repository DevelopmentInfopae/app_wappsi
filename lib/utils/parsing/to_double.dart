double parsingToDouble(var value) {
  double d = 0.0;
  if (value != null) {
    if (value != '') {
      d = double.tryParse(value.toString()) ?? 0.0;
    }
  }
  return d;
}
