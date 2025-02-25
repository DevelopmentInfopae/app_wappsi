Map getVerificationCode(String nit) {
  nit.replaceAll(' ', '');
  nit.replaceAll(',', '');
  nit.replaceAll('.', '');
  nit.replaceAll('-', '');
  if ((int.tryParse(nit) ?? '') == '') {
    return {
      'error': true,
      'message': 'El NIT $nit no es válido(a).',
      'value': '',
    };
  }

  List<int> vpri = [
    3,
    7,
    13,
    17,
    19,
    23,
    29,
    37,
    41,
    43,
    47,
    53,
    59,
    67,
    71,
  ];
  int x = 0;
  int y = 0;

  for (int i = 0; i < nit.length; i++) {
    y = int.parse(nit.substring(i, i + 1));
    x += y * vpri[nit.length - (i + 1)];
  }
  y = x % 11;

  return {
    'error': false,
    'message': 'Exito',
    'value': y > 1 ? (11 - y).toString() : y.toString(),
  };
}
