import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaflets/screens/journal_entry_page.dart';
import 'package:leaflets/screens/note_entry_page.dart';
import 'package:leaflets/screens/task_entry_page.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/journal_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/notes_page.dart';
import 'screens/folders_page.dart';
import 'screens/tasks_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const LeafletsApp());
}

class LeafletsApp extends StatelessWidget {
  const LeafletsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaflets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C834F),
          primary: const Color(0xFF9C834F),
          background: const Color(0xFFB3DB85),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/journal': (context) => const JournalPage(),
        '/notes': (context) => const NotesPage(),
        '/folders': (context) => const FoldersPage(),
        '/tasks': (context) => const TasksPage(),
        '/journalentry': (context) => const JournalEntryPage(),
        '/noteentry': (context) => const NoteEntryPage(),
        '/taskentry': (context) => const TaskEntryPage(),
      },
    );
  }
}