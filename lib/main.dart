import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/constants/app_constants.dart';
import 'package:idoc_user/data/repostories/category_repository.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/data/repostories/favorites_repository.dart';
import 'package:idoc_user/data/repostories/user_call_repository.dart';
import 'package:idoc_user/data/services/appointment_service.dart';
import 'package:idoc_user/data/services/doctor_availability_service.dart';
import 'package:idoc_user/data/services/notification_service.dart';
import 'package:idoc_user/data/services/payment_service.dart';
import 'package:idoc_user/firebase_options.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_state.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_in/sign_in_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_up/sign_up_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_bloc.dart';
import 'package:idoc_user/logic/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_event.dart';
import 'package:idoc_user/logic/blocs/category/category_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_event.dart';
import 'package:idoc_user/logic/blocs/chat/chat_bloc.dart';
import 'package:idoc_user/logic/blocs/doctor_detail/doctor_detail_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/featured_doctors/featured_doctors_bloc.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_bloc.dart';
import 'package:idoc_user/logic/blocs/forgot_password/forgot_password_bloc.dart';
import 'package:idoc_user/logic/blocs/notification/notification_bloc.dart';
import 'package:idoc_user/logic/blocs/notification/notification_event.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_bloc.dart';
import 'package:idoc_user/logic/blocs/payment/payment_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/settings/settings_bloc.dart';
import 'package:idoc_user/logic/blocs/splash/splash_bloc.dart';
import 'package:idoc_user/logic/blocs/splash/splash_event.dart';
import 'package:idoc_user/presentation/screens/call/widgets/call_listener/call_listener_wrapper.dart';
import 'package:idoc_user/presentation/screens/splash/splash_screen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  await NotificationService.instance.initialize();

  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseFirestore>(create: (context) => firestore),
        RepositoryProvider<PaymentService>(
          create: (context) => PaymentService(firestore),
        ),
        RepositoryProvider<AppointmentService>(
          create: (context) => AppointmentService(firestore),
        ),
        RepositoryProvider<DoctorAvailabilityService>(
          create: (context) => DoctorAvailabilityService(firestore),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(),
        ),
        RepositoryProvider<DoctorRepository>(
          create: (context) => DoctorRepository(),
        ),
        RepositoryProvider<FavoritesRepository>(
          create: (context) => FavoritesRepository(),
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
          BlocProvider(create: (context) => UserChatBloc()),

          BlocProvider<CategoryBloc>(
            create:
                (context) =>
                    CategoryBloc(context.read<CategoryRepository>())
                      ..add(SubscribeToCategoriesEvent()),
          ),
          BlocProvider<DoctorBloc>(
            create:
                (context) => DoctorBloc(
                  context.read<DoctorRepository>(),
                  context.read<DoctorAvailabilityService>(),
                ),
          ),
          BlocProvider(
            create: (context) => DoctorDetailBloc(DoctorRepository()),
          ),
          BlocProvider<FeaturedDoctorsBloc>(
            create:
                (context) =>
                    FeaturedDoctorsBloc(context.read<DoctorRepository>()),
          ),
          BlocProvider<FavoritesBloc>(
            create:
                (context) => FavoritesBloc(
                  favoritesRepository: context.read<FavoritesRepository>(),
                  doctorRepository: context.read<DoctorRepository>(),
                )..add(LoadFavorites()),
          ),
          BlocProvider<AppointmentBloc>(
            create:
                (context) => AppointmentBloc(
                  appointmentService: context.read<AppointmentService>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => AppointmentsListBloc(
                  appointmentService: context.read<AppointmentService>(),
                ),
          ),
          BlocProvider<PaymentBloc>(
            create:
                (context) => PaymentBloc(
                  paymentService: context.read<PaymentService>(),
                  appointmentService: context.read<AppointmentService>(),
                ),
          ),
          BlocProvider<UserCallBloc>(
            lazy: false,
            create:
                (context) => UserCallBloc(
                  repository: UserCallRepository(),
                  appId: AppConstants.agoraAppId,
                ),
          ),
          BlocProvider(create: (context) => NotificationBloc()),
          BlocProvider(create: (context) => NotificationHistoryBloc()),
          BlocProvider(create: (context) => SettingsBloc()),
        ],

        child: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  String? _listeningUserId;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        final callBloc = context.read<UserCallBloc>();
        final notifBloc = context.read<NotificationBloc>();

        if (authState is AuthAuthenticated) {
          final uid = authState.user.uid;

          // Only subscribe once per logged-in user.
          if (_listeningUserId != uid) {
            _listeningUserId = uid;
            callBloc.add(StartListeningForCalls(uid));
            debugPrint('✅ [CallListener] Started for uid=$uid');

            // Initialize notification system for this user.
            notifBloc.add(InitializeNotifications(userId: uid));
            debugPrint('✅ [NotificationBloc] Initialized for uid=$uid');
          }
        } else if (authState is AuthUnauthenticated) {
          // User logged out — cancel the Firestore stream.
          if (_listeningUserId != null) {
            final previousUid = _listeningUserId!;
            _listeningUserId = null;
            callBloc.add(const StopListeningForCalls());
            debugPrint('[CallListener] Stopped — user logged out');

            // Stop notifications and remove FCM token.
            notifBloc.add(StopNotifications(userId: previousUid));
            debugPrint('[NotificationBloc] Stopped — user logged out');
          }
        }
      },
      child: MaterialApp(
        title: 'iDoc-user',
        theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        navigatorKey: _navigatorKey,
        builder:
            (context, child) => CallListenerWrapper(
              navigatorKey: _navigatorKey,
              child: child ?? const SizedBox.shrink(),
            ),
      ),
    );
  }
}
