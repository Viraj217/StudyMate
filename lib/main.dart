import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studymate/features/auth/domain/repos/firebase_todo_repo.dart';
import 'package:studymate/features/auth/domain/repos/note_repo.dart';
import 'package:studymate/features/auth/presentation/cubits/auth_states.dart';
import 'package:studymate/features/auth/presentation/cubits/note_cubits.dart';
import 'package:studymate/features/auth/presentation/pages/auth_page.dart';
import 'package:studymate/firebase_options.dart';
import 'package:studymate/themes/light_mode.dart';
import 'features/auth/data/firebase_auth_repo.dart';
import 'features/auth/presentation/cubits/auth_cubits.dart';
import 'features/auth/presentation/cubits/todo_cubit.dart';
import 'features/home/presentation/pages/main_screen_page.dart';
import 'features/home/presentation/pages/splash_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Required for async binding
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firestore settings based on platform
  if (!kIsWeb) {
    // Only enable persistence on mobile/desktop platforms
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } else {
    // Web-specific settings (persistence is enabled by default on web)
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, // Already enabled by default on web
    );
  }

  // Load .env file (conditional for web)
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Error loading .env: $e");
    }
  } else {
    // For web, you might want to use environment variables differently
    // or load them from a web-specific configuration
    print("Running on web - .env loading skipped");
  }

  // Create repos here
  final firebaseAuthRepo = FirebaseAuthRepo();

  // Now run entire app structure from here
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,

        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            print(state);

            if (state is UnAuthenticated) {
              return AuthPage();
            }

            if (state is Authenticated) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) =>
                        TodoCubit(FirebaseTodoRepo(state.user.uid)),
                  ),
                  BlocProvider(
                    create: (_) =>
                        NotesCubit(NotesRepository())..loadNotes(),
                  ),
                ],
                child: MainScreenPage(),
              );
            }
            return SplashScreen();
          },

          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    ),
  );
}