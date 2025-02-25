// ignore_for_file: unnecessary_string_escapes

import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

// import 'dart:math';

Map<String, dynamic> replaceStringInMap(
  Map map,
  String oldString,
  String newString,
) {
  String stMap = jsonEncode(map);

  stMap.replaceAll(oldString, newString);

  return jsonDecode(stMap);
}

bool isNumeric(String s) {
  // ignore: unnecessary_null_comparison
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

bool isNumericInt(String s) {
  // ignore: unnecessary_null_comparison
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}

List getKeyValuesOfListMap(List<Map> map, String key) {
  if (map.isNotEmpty) {
    final List temp = [];
    try {
      for (var m in map) {
        temp.add(m[key]);
      }
    } catch (e) {
      printConsole(e);
    }
    return temp;
  } else {
    return [];
  }
}
// int abd(int i){
//   return int.parse(sqrt().toString());
// }

String getFormatedCurrency(double value, {int? decimals}) {
  final _formatCurrency = NumberFormat.simpleCurrency(
    decimalDigits: decimals ?? dataBloc.settings?['decimals'],
  );
  return _formatCurrency.format(value);
}

double roundDouble(double value, int places) {
  double mod = pow(10.0, places).toDouble();
  return ((value * mod).round().toDouble() / mod);
}

String getRoundedQtty(double double) {
  double = roundDouble(double, dataBloc.settings!['qty_decimals']);
  String value = '';
  if (double.toString().endsWith('.0')) {
    value = double.toInt().toString();
  } else {
    value = double.toString();
  }
  return value;
}

List<String> removeRareSpaceChr(String input) {
  input = input.trimRight();
  input = input.trimLeft();
  final l = input.split('<p>');
  List<String> output = [];
  for (var element in l) {
    String temp = replaceSpecialCharacters(element);
    temp = temp.trim();
    output.add(temp);
  }
  return output;
}

String replaceSpecialCharacters(String character) {
  final chr = [
    {'from': 'á', 'replace': 'a'},
    {'from': 'Á', 'replace': 'A'},
    {'from': 'é', 'replace': 'e'},
    {'from': 'é', 'replace': 'E'},
    {'from': 'í', 'replace': 'i'},
    {'from': 'Í', 'replace': 'I'},
    {'from': 'ó', 'replace': 'o'},
    {'from': 'Ó', 'replace': 'O'},
    {'from': 'ú', 'replace': 'u'},
    {'from': 'Ú', 'replace': 'U'},
    {'from': 'ñ', 'replace': 'n'},
    {'from': 'Ñ', 'replace': 'N'},
    {'from': '<p>', 'replace': ''},
    {'from': '</p>', 'replace': ''},
  ];
  for (var element in chr) {
    character = character.replaceAll(element['from']!, element['replace']!);
  }
  return character;
}

String capitalizeText(String value) {
  final specialUpperCases = [
    's.a',
    'sa',
    'sas',
    's.a.s',
    'pos',
    's.a.s.',
    'pvp',
    'iva',
    'fb',
    '"adis"',
  ];
  final specialLowerCases = ['de', 'la', 'el', 'los', 'las', 'y', 'o', 'con'];
  if (value.endsWith(' ')) {
    value = value.substring(0, value.length - 1);
  }
  if (value.isNotEmpty) {
    List<String> words = value.split(' ');
    if (words.isEmpty) {
      words = value.split('  ');
    }
    String output = '';
    if (words.isNotEmpty) {
      for (var element in words) {
        final temp = element.toLowerCase();
        if (element == words.first && element.isNotEmpty) {
          output =
              output + temp.substring(0, 1).toUpperCase() + temp.substring(1);
        } else if (element.isNotEmpty) {
          if (specialUpperCases
              .where((element) => element == temp)
              .isNotEmpty) {
            output = output + ' ' + temp.toUpperCase();
          } else if (specialLowerCases
              .where((element) => element == temp)
              .isNotEmpty) {
            output = output + ' ' + temp;
          } else {
            output = output +
                ' ' +
                temp.substring(0, 1).toUpperCase() +
                temp.substring(1) +
                ' ';
          }
        }
      }
    } else {
      final temp = value.toLowerCase();
      output = temp.substring(0, 1).toUpperCase() + temp.substring(1);
    }
    printConsole(output);
    return output;
  } else {
    return value;
  }
}

String getStringFromValues(var values) {
  String string = '';

  for (var i = 0; i < values.length; i++) {
    if (i == 0) {
      if (values.elementAt(i) == null || values.elementAt(i) == '') {
        string = string + 'null';
      } else {
        var val = values.elementAt(i);
        String valString;
        if (val is String) {
          valString = val;
          try {
            final temp = jsonDecode(valString);
            if ((temp is! Map)) {
              valString = valString.replaceAll('"', '\"').replaceAll("'", "\'");
            }
          } catch (e) {
            // printConsole(e);
          }
        } else if (val is num) {
          valString = val.toString();
        } else {
          if (val is Map) {
            valString = jsonEncode(val);
            // valString =  valString.replaceAll(from, replace)
          } else {
            valString =
                val.toString().replaceAll('"', '\"').replaceAll("'", "\'");
          }
        }
        // printConsole(valString);
        string = string + '"' + valString + '"';
      }
    } else {
      if (values.elementAt(i) == null) {
        string = string + ',null';
      } else {
        var val = values.elementAt(i);
        String valString;
        if (val is String) {
          valString = val;
          try {
            final temp = jsonDecode(valString);
            if (temp is! num) {
              if ((temp is! Map)) {
                valString =
                    valString.replaceAll('"', '\"').replaceAll("'", "\'");
              } else {
                valString = valString
                    .replaceAll('"{', '{')
                    .replaceAll('}"', '}')
                    .replaceAll('"', "'");
              }
            }
          } catch (e) {
            // printConsole(e);
          }
        } else if (val is num) {
          valString = val.toString();
        } else {
          if (val is Map) {
            valString = jsonEncode(val);
            valString = valString
              ..replaceAll('"{', '{')
                  .replaceAll('}"', '}')
                  .replaceAll('"', "'");
            // valString =  valString.replaceAll(from, replace)
          } else {
            valString =
                val.toString().replaceAll('"', '\"').replaceAll("'", "\'");
          }
        }
        // printConsole(valString);
        // if(jsonDecode(valString)is Map){
        string = string + ',"' + valString + '"';
        // }else{
        //   // ignore: unnecessary_string_escapes
        //   valString = valString.replaceAll('"', '\"').replaceAll("'", "\'");
        //   string = string + ',"' + valString + '"';
        // }
        // string = string + ',"' + valString + '"';
      }
    }
  }

  return string.replaceAll('""{', '"{').replaceAll('}""', '}"');
}

String getEmptySpaces(int n) {
  String empty = Environment().config.printErrors ? '-' : ' ';

  return empty * n;
}
