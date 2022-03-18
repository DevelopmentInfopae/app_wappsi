import 'package:pos_wappsi/providers/local_db_provider.dart';

Future<void> logError(var e,{String from='local db operations'})async{
  await DBProvider.db.printAndSaveError(e);
}