import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rinsr_delivery_partner/core/constants/constants.dart';
import 'package:rinsr_delivery_partner/features/order/data/models/accept_order_response_model/accept_order_response_model.dart';
import 'package:rinsr_delivery_partner/features/order/data/models/notify_users_response_model/notify_users_response_model.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../models/update_order_model/update_order_model.dart';

abstract class OrderRemoteDataSource {
  Future<UpdateOrderModel> updateOrder({
    required String orderId,
    required String status,
    String? photoPath,
  });
  Future<NotifyUsersResponseModel> notifyUsers(String orderId);
  Future<AcceptOrderResponseModel> acceptOrder(String orderId, String type);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl(this.dio);
  @override
  Future<UpdateOrderModel> updateOrder({
    required String orderId,
    required String status,
    String? photoPath,
  }) async {
    dynamic data;

    if (photoPath != null) {
      if (kDebugMode) {
        print({'status': status, 'image': photoPath}.toString());
      }
      data = FormData.fromMap({
        'delivery_id': SharedPreferencesService.getString(
          AppConstants.kAgentId,
        ),
        'status': status,
        'image': await MultipartFile.fromFile(photoPath),
      });
    } else {
      data = {
        'status': status,
        'delivery_id': SharedPreferencesService.getString(
          AppConstants.kAgentId,
        ),
      };
    }

    final Response response = await dio.put(
      '${ApiUrls.getOrders}/$orderId',
      data: data,
    );
    return UpdateOrderModel.fromJson(response.data);
  }

  @override
  Future<NotifyUsersResponseModel> notifyUsers(String orderId) async {
    final Response response = await dio.post(
      ApiUrls.notifyUser,
      data: {'orderId': orderId},
    );
    return NotifyUsersResponseModel.fromJson(response.data);
  }

  @override
  Future<AcceptOrderResponseModel> acceptOrder(
    String orderId,
    String type,
  ) async {
    final Response response = await dio.patch(
      'orders/$orderId/accept-delivery',
      data: {'type': type},
    );
    return AcceptOrderResponseModel.fromJson(response.data);
  }
}
