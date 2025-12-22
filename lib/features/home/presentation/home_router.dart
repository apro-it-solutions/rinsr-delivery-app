import 'package:flutter/material.dart';
import '../../order/presentation/pages/order_detail_screen.dart';
import '../domain/entities/get_orders_entity.dart';
import 'pages/home_screen.dart';

import '../../profile/presentation/pages/profile_page.dart';

class HomeRouter {
  static const String home = '/home';
  static const String orderDetail = '/orderDetail';
  static const String profile = '/profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case orderDetail:
        final orderId = settings.arguments as OrderDetailsEntity;
        return MaterialPageRoute(
          builder: (context) => OrderDetailScreen(order: orderId),
        );
      case profile:
        return MaterialPageRoute(builder: (context) => const ProfilePage());
    }
    return null;
  }
}
