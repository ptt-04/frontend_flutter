import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/create_booking_screen.dart';
import '../screens/booking/service_selection_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/shop/product_detail_screen.dart';
import '../screens/shop/cart_screen.dart';
import '../screens/shop/checkout_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/booking_history_screen.dart';
import '../screens/profile/my_orders_screen.dart';
import '../screens/profile/help_center_screen.dart';
import '../screens/profile/contact_support_screen.dart';
import '../screens/profile/about_app_screen.dart';
import '../screens/ai/ai_chat_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/voucher/voucher_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/admin/service_management_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      
      // If not authenticated and not on auth screens, redirect to login
      if (!isAuthenticated && 
          !state.uri.toString().startsWith('/login') && 
          !state.uri.toString().startsWith('/register') &&
          state.uri.toString() != '/splash') {
        return '/login';
      }
      
      // If authenticated and on auth screens, redirect to home
      if (isAuthenticated && 
          (state.uri.toString().startsWith('/login') || 
           state.uri.toString().startsWith('/register'))) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: '/booking/service-selection',
        builder: (context, state) => const ServiceSelectionScreen(),
      ),
      GoRoute(
        path: '/booking/create',
        builder: (context, state) => const CreateBookingScreen(),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        path: '/shop/product/:id',
        builder: (context, state) {
          final productId = int.parse(state.pathParameters['id']!);
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/booking-history',
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: '/profile/my-orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/profile/help-center',
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/profile/contact-support',
        builder: (context, state) => const ContactSupportScreen(),
      ),
      GoRoute(
        path: '/profile/about-app',
        builder: (context, state) => const AboutAppScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AIChatScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/vouchers',
        builder: (context, state) => const VoucherScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/admin/service-management',
        builder: (context, state) => const ServiceManagementScreen(),
      ),
    ],
  );
}
