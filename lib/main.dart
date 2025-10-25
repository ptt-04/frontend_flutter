import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider_new.dart';
import 'providers/voucher_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/order_provider.dart';
import 'services/storage_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await ApiConfig.loadEnv();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize services
  await StorageService.init();
  
  runApp(const BarberShopApp());
}

class BarberShopApp extends StatelessWidget {
  const BarberShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'BarberShop',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}