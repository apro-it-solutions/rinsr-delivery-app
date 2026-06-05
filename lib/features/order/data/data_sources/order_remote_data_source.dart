import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/constants.dart';
import '../models/accept_order_response_model/accept_order_response_model.dart';
import '../models/notify_users_response_model/notify_users_response_model.dart';
import '../models/mark_payment_received_response_model.dart';
import '../models/cancel_order_response_model.dart';
import '../models/payment_qr_response_model.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/services/shared_preferences_service.dart';
import '../models/update_order_model/update_order_model.dart';

abstract class OrderRemoteDataSource {
  Future<UpdateOrderModel> updateOrder({
    required String orderId,
    required String status,
    String? photoPath,
    String? weight,
    String? barcode,
  });
  Future<NotifyUsersResponseModel> notifyUsers(String orderId);
  Future<AcceptOrderResponseModel> acceptOrder(String orderId, String type);
  Future<MarkPaymentReceivedResponseModel> markPaymentReceived(String orderId);
  Future<CancelOrderResponseModel> cancelOrder(String orderId, String reason);
  Future<PaymentQrResponseModel> getPaymentQr(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl(this.dio);
  @override
  Future<UpdateOrderModel> updateOrder({
    required String orderId,
    required String status,
    String? photoPath,
    String? weight,
    String? barcode,
  }) async {
    dynamic data;

    if (photoPath != null) {
      if (kDebugMode) {
        print(
          {
            'status': status,
            'image': photoPath,
            if (weight != null) 'weight': weight,
            if (barcode != null) 'barcode': barcode,
          }.toString(),
        );
      }
      data = FormData.fromMap({
        'delivery_id': SharedPreferencesService.getString(
          AppConstants.kAgentId,
        ),
        'status': status,
        'image': await MultipartFile.fromFile(photoPath),
        if (weight != null) 'total_weight_kg': weight,
        if (barcode != null) 'barcode_id': barcode,
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

  @override
  Future<MarkPaymentReceivedResponseModel> markPaymentReceived(
    String orderId,
  ) async {
    final Response response = await dio.patch(
      ApiUrls.recordCashPayment(orderId),
    );
    return MarkPaymentReceivedResponseModel.fromJson(response.data);
  }

  @override
  Future<PaymentQrResponseModel> getPaymentQr(String orderId) async {
    final Response response = await dio.get(ApiUrls.paymentQr(orderId));
    return PaymentQrResponseModel.fromJson(response.data);
  }

  @override
  Future<CancelOrderResponseModel> cancelOrder(
    String orderId,
    String reason,
  ) async {
    final Response response = await dio.patch(
      ApiUrls.cancelOrder(orderId),
      data: {
        'cancel_reason': reason,
        'delivery_id': SharedPreferencesService.getString(
          AppConstants.kAgentId,
        ),
      },
    );
    return CancelOrderResponseModel.fromJson(response.data);
  }
}
