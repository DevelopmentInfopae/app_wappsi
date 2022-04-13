double parsingToDouble(var value) {
  double d = 0.0;
  if (value != null) {
    if (value != '') {
      d = double.tryParse(value.toString()) ?? 0.0;
    }
  }
  return d;
}

double? parsingToDoubleNullAble(var value) {
  double? d;
  if (value != null) {
    if (value != '') {
      d = double.tryParse(value.toString()) ?? 0.0;
    }
  }
  return d;
}

int parsingToInt(var value) {
  int d = 0;
  if (value != null) {
    if (value != '') {
      d = int.tryParse(value.toString()) ?? 0;
    }
  }
  return d;
}
