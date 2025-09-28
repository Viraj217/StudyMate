import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studymate/features/auth/presentation/cubits/auth_states.dart';
import 'package:studymate/features/auth/presentation/pages/auth_page.dart';
import 'package:studymate/firebase_options.dart';
import 'package:studymate/themes/light_mode.dart';
import 'features/auth/data/firebase_auth_repo.dart';
import 'features/auth/presentation/cubits/auth_cubits.dart';
import 'features/home/presentation/pages/main_screen_page.dart';
import 'features/home/presentation/pages/splash_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // You may want to log an error or fail startup if the file is critical
    print('Error loading .env file: $e');
  }

  //run application
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //provide cubits to the app
        providers: [
          //auth cubit
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
          ),
        ],

        //app
        child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: lightMode,
                /*
                BLOC CONSUMER - Auth
                */
                home: BlocConsumer<AuthCubit, AuthState>(
                  builder: (context, state){
                    print(state);
                    //unauthenticated -> auth page
                    if (state is UnAuthenticated) {
                      return AuthPage();
                    }
                    //authenticated -> home page
                    if (state is Authenticated) {
                      return MainScreenPage();
                    }
                    //loading..
                    else {
                      return SplashScreen();
                    }

                  },
                  listener: (context, state){
                    //auth error
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
    );
  }
}
