import 'package:flutter/material.dart';

/// Global navigator key để Dio interceptor có thể redirect khi token hết hạn
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
