import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/data/repostories/category_repository.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/data/services/appointment_service.dart';
import 'package:idoc_user/firebase_options.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_in/sign_in_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_up/sign_up_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_bloc.dart';
import 'package:idoc_user/logic/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_event.dart';
import 'package:idoc_user/logic/blocs/doctor_detail/doctor_detail_bloc.dart'; 
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/forgot_password/forgot_password_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/splash/splash_bloc.dart';
import 'package:idoc_user/logic/blocs/splash/splash_event.dart';
import 'package:idoc_user/presentation/screens/splash/splash_screen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(StudentApp());
}
class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(),
        ),
        RepositoryProvider<DoctorRepository>(
          create: (context) => DoctorRepository(),
        ),
        RepositoryProvider<AppointmentService>(
          create: (context) => AppointmentService(FirebaseFirestore.instance),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SplashBloc()..add(StartSplash())),
          BlocProvider(create: (context) => SignUpBloc()),
          BlocProvider(create: (context) => SignInBloc()),
          BlocProvider(create: (context) => BottomNavBloc()),
          BlocProvider(create: (context) => ProfileBloc()),
          BlocProvider(create: (context) => LogoutBloc()),
          BlocProvider(create: (context) => ForgotPasswordBloc()),
          BlocProvider(create: (context) => AuthBloc()),
         BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              context.read<CategoryRepository>(),
            )..add(SubscribeToCategoriesEvent()),
          ),
          
          BlocProvider<DoctorBloc>(
            create: (context) => DoctorBloc(
              context.read<DoctorRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => DoctorDetailBloc(DoctorRepository()),
          ),
          BlocProvider<AppointmentBloc>(
  create: (context) => AppointmentBloc(
    appointmentService: context.read<AppointmentService>(),
  ),
),
BlocProvider(create: (context) => AppointmentsListBloc(appointmentService: context.read<AppointmentService>())),

        ],
        child: MaterialApp(
          home: const SplashScreen(),
          title: 'iDoc-user',
          theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}