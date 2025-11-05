import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/pokemon_list_screen.dart';
import 'services/poke_api.dart';

void main() {
  // Initialize GraphQL client before running the app
  PokeApi.initGraphQL();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFFE63946),      // Rojo vibrante
          secondary: const Color(0xFF457B9D),    // Azul
          tertiary: const Color(0xFFF77F00),     // Naranja
          surface: const Color(0xFFF1FAEE),      // Blanco suave
          primaryContainer: const Color(0xFFFFB3C1),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.limelight(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 1.5),
          displayMedium: GoogleFonts.limelight(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 1.2),
          headlineMedium: GoogleFonts.limelight(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 1.0),
          headlineSmall: GoogleFonts.limelight(fontSize: 20, fontWeight: FontWeight.w400, letterSpacing: 0.8),
          titleLarge: GoogleFonts.limelight(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 0.5),
          bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.3),
          bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.2),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFE63946),
          titleTextStyle: GoogleFonts.limelight(
            fontSize: 26,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFFB3C1),
          labelStyle: const TextStyle(
            color: Color(0xFF1D3557),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE63946),
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFFF77F00),
          foregroundColor: Colors.white,
          elevation: 6,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE63946), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF457B9D), width: 2),
          ),
        ),
      ),
      home: const PokemonListScreen(),
    );
  }
}
