import 'package:pos_wappsi/providers/local_db_provider.dart';

Future<void> logError(var e,{String from='local db operations'})async{
  print('--- ERROR DETECTADO ---');
  print('Origen: $from');
  print('Error: $e');
  await DBProvider.db.printAndSaveError(e);
}