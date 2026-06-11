class ApiUrls {
  static const String firebaseAuth = '/delivery-partners/firebase';
  static const String saveToken = 'delivery-partners/device-token';
  static const String getOrders = 'orders';
  static const String getDeliveryPartnerOrders = 'orders/delivery-partner';
  static const String getAgentDetails = 'delivery-partners/me';
  static const String toggleActive = 'delivery-partners/me/active';
  static const String updateProfileImage = 'delivery-partners/me/profile-image';
  static String getRatings(String partnerId) =>
      'ratings/delivery-partner/$partnerId';
  static const String notifyUser = 'delivery-notifications/notify-user';
  static const String driverTrackingUpdate = 'tracking/driver/update';
  static String recordCashPayment(String orderId) =>
      'orders/$orderId/record-cash-payment';
  static String cancelOrder(String orderId) => 'orders/$orderId/cancel';
  static String paymentQr(String orderId) => 'orders/$orderId/payment-qr';
}
