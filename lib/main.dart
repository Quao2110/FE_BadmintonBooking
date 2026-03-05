import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/court/court_bloc.dart';
import 'presentation/bloc/shop/shop_bloc.dart';
import 'presentation/bloc/shop/shop_event.dart';
import 'routes/app_router.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc.create()..add(const CheckAuthEvent()),
        ),
        BlocProvider<ShopBloc>(
          create: (_) => ShopBloc.create()..add(const LoadShopInfo()),
        ),
        BlocProvider<CourtBloc>(
          create: (_) => CourtBloc.create(),
        ),
      ],
      child: MaterialApp(
        title: 'Badminton App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
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
