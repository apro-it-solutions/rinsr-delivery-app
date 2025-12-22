import 'package:dio/dio.dart';
import '../../../../core/constants/api_urls.dart';
import '../models/get_orders_model/get_orders_model.dart';

abstract class HomeRemoteDataSource {
  Future<GetOrdersModel> getOrders();
}

class HomeRemoteDataSourceImpl extends HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl(this.dio);
  @override
  Future<GetOrdersModel> getOrders() async {
    final Response response = await dio.get(ApiUrls.getOrders);
    return GetOrdersModel.fromJson(response.data);
  }
}
