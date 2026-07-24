import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/start_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.requestPermission();
  final token = await FirebaseMessaging.instance.getToken();
  print(token);

  runApp(const ProviderScope(child: AsiCityApp()));
}

class AsiCityApp extends ConsumerWidget {
  const AsiCityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'AsiCity',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const StartScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Erro: $err')),
        ),
      ),
    );
  }
}

ThemeData _buildAppTheme() {
  final textTheme = GoogleFonts.inriaSansTextTheme().apply(
    bodyColor: Color.fromARGB(255, 249, 252, 255),
    displayColor: Color.fromARGB(255, 249, 252, 255),
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Color.fromARGB(255, 61, 69, 83),
    textTheme: textTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 61, 69, 83),
      iconTheme: const IconThemeData(color: Color.fromARGB(255, 249, 252, 255)),
      titleTextStyle: GoogleFonts.inriaSans(
        color: Color.fromARGB(255, 249, 252, 255),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    cardTheme: CardThemeData(
      color: Color.fromARGB(255, 57, 64, 77)
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 57, 64, 77),
        foregroundColor: Color.fromARGB(255, 249, 252, 255),
        side: const BorderSide(color: Color.fromARGB(255, 249, 252, 255), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inriaSans(fontWeight: FontWeight.bold),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Color.fromARGB(255, 71, 143, 211), // azul de destaque
      foregroundColor: Color.fromARGB(255, 249, 252, 255), // ícone branco
    ),

    iconTheme: const IconThemeData(color: Color.fromARGB(255, 71, 143, 211)),

    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.inriaSans(color: Color.fromARGB(255, 249, 252, 255)),
      hintStyle: GoogleFonts.inriaSans(color: Color.fromARGB(255, 249, 252, 255)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 145, 161, 187)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 71, 143, 211)),
      ),
      border: const OutlineInputBorder(),
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color.fromARGB(255, 71, 143, 211),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(color:Color.fromARGB(255, 57, 64, 77)),
  );
}