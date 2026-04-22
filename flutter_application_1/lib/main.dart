import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1/bloc/auth/auth_event.dart';
import 'package:flutter_application_1/bloc/auth/auth_state.dart';
import 'package:flutter_application_1/bloc/post/post_cubit.dart';
import 'package:flutter_application_1/bloc/api/api_cubit.dart';
import 'package:flutter_application_1/bloc/theme/theme_cubit.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_application_1/network/api_client.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/main_page.dart';
import 'package:flutter_application_1/pages/register_page.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/repositories/post_repository.dart';
import 'package:flutter_application_1/translations/codegen_loader.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  final dio = Dio();
  final apiClient = ApiClient(dio);
  final postRepository = PostRepository();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('kk'), Locale('ru'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      assetLoader: const CodegenLoader(),
      child: MyApp(apiClient: apiClient, postRepository: postRepository),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final PostRepository postRepository;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.postRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider.value(value: postRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(
            create: (context) =>
                AuthBloc(context.read<AuthRepository>())
                  ..add(CheckAuthStatusEvent()),
          ),
          BlocProvider(
            create: (context) => PostCubit(postRepository)..fetchPosts(),
          ),
          BlocProvider(
            create: (context) => ApiCubit(apiClient)..fetchExploreData(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              themeMode: themeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: AppColors.backgroundLight,
                primaryColor: AppColors.primaryBlue,
                cardTheme: const CardThemeData(
                  color: Colors.white,
                  elevation: 0.5,
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: AppColors.textPrimary),
                ),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryBlue,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: AppColors.darkBackground,
                primaryColor: AppColors.primaryBlue,
                cardTheme: CardThemeData(
                  color: AppColors.darkSurface,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: AppColors.textLight),
                  bodyMedium: TextStyle(color: Colors.white70),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: AppColors.darkSurface,
                  selectedItemColor: AppColors.primaryBlue,
                  unselectedItemColor: Colors.grey,
                  type: BottomNavigationBarType.fixed,
                  elevation: 10,
                ),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryBlue,
                  brightness: Brightness.dark,
                  surface: AppColors.darkSurface,
                ),
              ),
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              title: 'Social Hub',
              initialRoute: '/',
              routes: {
                '/': (context) => BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthSuccess) return const MainPage();
                    return const LoginPage();
                  },
                ),
                '/login': (context) => const LoginPage(),
                '/register': (context) => const RegisterFormPage(),
                '/home': (context) => const MainPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
