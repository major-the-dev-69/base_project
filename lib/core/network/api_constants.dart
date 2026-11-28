class ApiConstants {
  ApiConstants._();

  // Base Config
  static const defaultApiBaseUrl = 'https://goservicesolutions.org/api/v1';
  static const appKey = 'gs_live_app_9a8f4c2e6b1d830f';

  // 1. Authentication & Profile
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const profile = '/auth/profile';
  static const addresses = '/auth/addresses';
  static String deleteAddress(dynamic id) {
    return '/auth/addresses/$id';
  }

  static const logout = '/auth/logout';

  // 2. Wallets & Redeem Discounts
  static const walletBalances = '/wallets/balances';
  static const calculateDiscount = '/wallets/calculate-discount';
  static const walletTransactions = '/wallets/transactions';

  // 3. Store & Products Catalog
  static const banners = '/banners';
  static const productCategories = '/products/categories';
  static const products = '/products';
  static const searchProducts = '/products/search';
  static String productDetails(dynamic id) {
    return '/products/$id';
  }

  // 4. Shopping Cart & Checkout
  static const checkoutQuote = '/checkout/quote';
  static const createOrder = '/checkout/create-order';
  static const verifyPayment = '/checkout/verify-payment';

  // 5. Recharge & Utility Bill Payment
  static const rechargeOperators = '/recharge/operators';
  static const rechargeCircles = '/recharge/circles';
  static const rechargePlans = '/recharge/plans';
  static const rechargeQuote = '/recharge/quote';
  static const rechargePay = '/recharge/pay';
  static String rechargeStatus(dynamic tId) {
    return '/recharge/status/$tId';
  }

  // 6. Reports & Tracking
  static const ordersHistory = '/reports/orders';
  static String orderDetails(dynamic orderId) {
    return '/reports/orders/$orderId';
  }

  static const rechargesHistory = '/reports/recharges';
  static const accountStatement = '/reports/statement';
}
