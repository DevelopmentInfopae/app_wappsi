import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/config/theme/app_theme.dart';
import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.PROD,
  );
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<Logger>(
    () => Logger(),
  );
  getIt.registerLazySingleton<GlobalKey<NavigatorState>>(
    () => GlobalKey<NavigatorState>(),
  );

  Environment().initConfig(environment);
  // add these lines
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    ProviderScope(child: Responsive(mobile: const MyApp())),
  );
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
      navigatorKey: GetIt.instance.get<GlobalKey<NavigatorState>>(),
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      theme: globalTheme(),
      title: 'WappsiPOSApp',
      initialRoute: '/',
      routes: Routes.getRoutes(),
    );
  }
}
