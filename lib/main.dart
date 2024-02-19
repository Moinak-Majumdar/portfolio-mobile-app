import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:portfolio/Hive/hive_flutter_cache.dart';
import 'package:portfolio/Hive/hive_user_playlist.dart';
import 'package:portfolio/Hive/hive_web_cache.dart';
import 'package:portfolio/auth/firebase_login.dart';
import 'package:portfolio/controller/music.dart';
import 'package:portfolio/firebase/firebase_options.dart';
import 'package:portfolio/Hive/hive_user_data.dart';
// import 'package:portfolio/utils/splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(HiveUserDataAdapter());
  Hive.registerAdapter(HiveUserPlaylistAdapter());
  Hive.registerAdapter(HiveWebCacheAdapter());
  Hive.registerAdapter(HiveFlutterCacheAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) {
    FlutterNativeSplash.remove();
    Get.put(MusicController());

    return GetMaterialApp(
      title: 'moinak05',
      theme: _getThemeData(),
      debugShowCheckedModeBanner: false,
      home: const FirebaseLogin(useBiometric: true),
      // test splash screen
      // home: const Splash(),
    );
  }
}

ThemeData _getThemeData() {
  return ThemeData().copyWith(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 91, 33, 182),
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      displayColor: Colors.grey.shade300,
      bodyColor: Colors.grey.shade300,
    ),
    appBarTheme: const AppBarTheme().copyWith(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.grey.shade900,
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    drawerTheme: const DrawerThemeData().copyWith(
      backgroundColor: const Color.fromARGB(255, 9, 9, 9),
    ),
    dialogTheme: const DialogTheme().copyWith(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
    ),
    bottomSheetTheme: const BottomSheetThemeData().copyWith(
      backgroundColor: const Color.fromARGB(255, 9, 9, 9),
    ),
    snackBarTheme: const SnackBarThemeData().copyWith(
      backgroundColor: Colors.black,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData().copyWith(
      color: const Color.fromARGB(255, 232, 152, 248),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      helperStyle: const TextStyle(
        color: Color.fromARGB(255, 202, 156, 239),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 202, 156, 239),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        disabledBackgroundColor: Colors.white10,
        disabledForegroundColor: Colors.white24,
      ),
    ),
    sliderTheme: const SliderThemeData().copyWith(
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
    ),
  );
}
