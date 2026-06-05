class ApiUrls {
  static const String firebaseAuth = '/delivery-partners/firebase';
  static const String saveToken = 'delivery-partners/device-token';
  static const String getOrders = 'orders';
  // Agent-scoped list: server returns only orders actionable by (or belonging
  // to) the authenticated delivery partner, unpaginated. Replaces the old
  // unscoped GET /orders for the home list, which was paginated and hid
  // actionable orders beyond page 1.
  static const String getDeliveryPartnerOrders = 'orders/delivery-partner';
  static const String getAgentDetails = 'delivery-partners/me';
  static const String toggleActive = 'delivery-partners/me/active';
  static const String updateProfileImage = 'delivery-partners/me/profile-image';
  static String getRatings(String partnerId) =>
      'ratings/delivery-partner/$partnerId';
  static const String notifyUser = 'delivery-notifications/notify-user';
  static String recordCashPayment(String orderId) =>
      'orders/$orderId/record-cash-payment';
  static String cancelOrder(String orderId) => 'orders/$orderId/cancel';

  // ⚠ Assumed contract (like cancelOrder was) — verify path + response shape
  // with backend before QA sign-off. Expected response:
  // { success, qr_string | upi_link | payment_link, qr_image_url?, amount? }
  static String paymentQr(String orderId) => 'orders/$orderId/payment-qr';
}
