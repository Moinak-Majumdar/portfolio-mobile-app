import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moinak05_web_dev_dashboard/app/auth/online_auth.dart';
import 'package:moinak05_web_dev_dashboard/hive_add_doc.dart';
import 'package:moinak05_web_dev_dashboard/hive_html.dart';
import 'package:moinak05_web_dev_dashboard/hive_music.dart';
import 'package:moinak05_web_dev_dashboard/hive_storage.dart';
import 'package:moinak05_web_dev_dashboard/provider/music.dart';
import 'firebase_options.dart';
import 'package:moinak05_web_dev_dashboard/app/utils/splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(HiveAddDocAdapter());
  Hive.registerAdapter(HiveHtmlAdapter());
  Hive.registerAdapter(HiveStorageAdapter());
  Hive.registerAdapter(HiveMusicAdapter());

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(context, ref) {
    ref.read(audioPlayerStart);
    FlutterNativeSplash.remove();

    return MaterialApp(
      title: '',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 150, 182, 197),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        textTheme: GoogleFonts.ubuntuTextTheme(),
      ),
      home: const OnlineAuth(),
    );
  }
}
