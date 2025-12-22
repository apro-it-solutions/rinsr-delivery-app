import '../../../../core/services/fcm_service.dart';
import '../../../../core/services/shared_preferences_service.dart';

abstract class AuthExternalServices {
  Future<void> setString(String key, String value);
  Future<void> registerVendor(String deliveryAgentId);
}

class AuthExternalServicesImpl implements AuthExternalServices {
  @override
  Future<void> setString(String key, String value) async {
    await SharedPreferencesService.setString(key, value);
  }

  @override
  Future<void> registerVendor(String deliveryAgentId) async {
    await FCMService.registerVendor(deliveryAgentId);
  }
}
