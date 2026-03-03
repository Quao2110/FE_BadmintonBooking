import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/notification_service.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'routes/app_router.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// Earthy Color Palette
const Color cafeNoir = Color(0xFF4C3D19);
const Color kombuGreen = Color(0xFF354024);
const Color mossGreen = Color(0xFF889063);
const Color tanColor = Color(0xFFCFBB99);
const Color boneColor = Color(0xFFE5D7C4);

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc.create()..add(const CheckAuthEvent()),
      child: MaterialApp(
        title: 'Badminton App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kombuGreen,
            primary: kombuGreen,
            secondary: mossGreen,
            tertiary: tanColor,
            surface: boneColor,
            onSurface: cafeNoir,
          ),
          scaffoldBackgroundColor: boneColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: kombuGreen,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: cafeNoir),
            bodyLarge: TextStyle(color: cafeNoir),
            bodyMedium: TextStyle(color: cafeNoir),
          ),
        ),
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) => _PermissionRequester(child: child!),
      ),
    );
  }
}

/// Widget wrapper xin quyền notification sau khi Flutter engine đã chạy.
/// Chỉ xin đúng 1 lần khi widget được mount.
class _PermissionRequester extends StatefulWidget {
  final Widget child;
  const _PermissionRequester({required this.child});

  @override
  State<_PermissionRequester> createState() => _PermissionRequesterState();
}

class _PermissionRequesterState extends State<_PermissionRequester> {
  @override
  void initState() {
    super.initState();
    // Chờ frame đầu tiên render xong rồi mới xin quyền
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}