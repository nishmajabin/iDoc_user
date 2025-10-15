import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/firebase_options.dart';
import 'package:second_project/logic/blocs/splash/splash_bloc.dart';
import 'package:second_project/logic/blocs/splash/splash_event.dart';
import 'package:second_project/presentation/screens/splash/splash_screen.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context)=> SplashBloc()..add(StartSplash()))
      ],
      child: MaterialApp(
        home: SplashScreen(),
        title: 'iDoc-user',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
