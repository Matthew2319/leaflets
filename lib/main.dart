import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:leaflets/screens/journal_entry_page.dart';
import 'package:leaflets/screens/note_entry_page.dart';
import 'package:leaflets/screens/task_entry_page.dart';
import 'package:leaflets/screens/welcome_screen.dart';
import 'package:leaflets/screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/journal_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/notes_page.dart';
import 'screens/folders_page.dart';
import 'screens/tasks_page.dart';
import 'firebase_options.dart';
import 'models/folder.dart';
import 'package:leaflets/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Remove or comment out the reCAPTCHA settings for now
  // await FirebaseAuth.instance.setSettings(
  //   appVerificationDisabledForTesting: false,
  //   phoneNumber: null,
  //   smsCode: null,
  //   forceRecaptchaFlow: false,
  // );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Remove this test line as it might interfere with initialization
  // await FirebaseFirestore.instance.collection('test').add({'test': 'value'});

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainScreen(),
        '/journal': (context) => const JournalPage(),
        '/notes': (context) => const NotesPage(),
        '/folders': (context) => const FoldersPage(
          folderType: FolderType.journal,
          title: 'FOLDERS',
        ),
        '/tasks': (context) => const TasksPage(),
        '/journalentry': (context) => const JournalEntryPage(),
        '/noteentry': (context) => const NoteEntryPage(),
        '/taskentry': (context) => const TaskEntryPage(),
      },
    );
  }
}