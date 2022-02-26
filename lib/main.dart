import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.DEV,
  );

  Environment().initConfig(environment);
  // add these lines
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  void initState() {
    _locale = const Locale('es');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,

      // TODO: make theme data of app here

      theme: ThemeData(
          primaryColor: const Color.fromRGBO(28, 122, 190, 1),
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              toolbarTextStyle: TextStyle(color: Colors.black, fontSize: 20)),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
            // backgroundColor: MaterialStateProperty.all(Colors.green)
            elevation: MaterialStateProperty.all(5),
            backgroundColor: MaterialStateProperty.all(Colors.white),
          )),
          iconTheme: const IconThemeData(color: Colors.black),
          primaryIconTheme: const IconThemeData(color: Colors.white),
          buttonTheme: const ButtonThemeData(
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
