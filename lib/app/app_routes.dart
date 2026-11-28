import 'package:get/get.dart';

class AppRoutes {
  // Root
  static const String init = '/init';
  static const String home = '/home';

  // 1. Authentication & Profile
  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String sendOtp = '/send-otp';
  static const String verifyOtp = '/verify-otp';
  static const String profile = '/profile';
  static const String addresses = '/addresses';

  // 2. Wallets & Redeem Discounts
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';

  // 3. Store & Products Catalog
  static const String shop = '/shop';
  static const String productCategories = '/products/categories';
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String productDetails = '/products/details';

  // 4. Shopping Cart & Checkout
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String verifyPayment = '/checkout/verify-payment';

  // 5. Recharge & Utility Bill Payment
  static const String recharge = '/recharge';
  static const String rechargeOperators = '/recharge/operators';
  static const String rechargeCircles = '/recharge/circles';
  static const String rechargePlans = '/recharge/plans';
  static const String rechargePay = '/recharge/pay';
  static const String rechargeStatus = '/recharge/status';

  // 6. Reports & Tracking
  static const String history = '/history';
  static const String ordersHistory = '/reports/orders';
  static const String orderDetails = '/reports/orders/details';
  static const String rechargesHistory = '/reports/recharges';
  static const String accountStatement = '/reports/statement';

  // Additional Features
  static const String member = '/member';
  static const String purchase = '/purchase';
  static const String setting = '/setting';
}

class AppPages extends AppRoutes {
  static const String initial = AppRoutes.init;

  static final List<GetPage<dynamic>> pages = [];
}
