import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();
  // add these lines
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  // const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // TODO: make theme data of app here

      theme: ThemeData(
          primaryColor: Color.fromRGBO(28, 122, 190, 1),
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              toolbarTextStyle: TextStyle(color: Colors.black, fontSize: 20)),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
            // backgroundColor: MaterialStateProperty.all(Colors.green)
            elevation: MaterialStateProperty.all(5),
            backgroundColor: MaterialStateProperty.all(Colors.white),
          )),
          iconTheme: IconThemeData(color: Colors.black),
          primaryIconTheme: IconThemeData(color: Colors.white),
          buttonTheme: ButtonThemeData(
              // textTheme: ButtonTextTheme.primary
              ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          backgroundColor: Colors.white),

      title: 'Mobile POS',
      initialRoute: '/',
      routes: Routes.getRoutes(),
    );
  }
}
