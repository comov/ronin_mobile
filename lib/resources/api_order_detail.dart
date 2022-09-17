import 'dart:convert';

import 'package:car_helper/entities/api.dart';
import 'package:car_helper/entities/order.dart';
import 'package:car_helper/main.dart';
import 'package:http/http.dart' as http;

class OrderDetailResponse {
  final int statusCode;

  final Order orderDetail;
  final ApiErrorResponse? error;

  const OrderDetailResponse({
    required this.statusCode,
    required this.orderDetail,
    this.error,
  });

}

Future<OrderDetailResponse> getOrderDetail(String authToken, int id) async {
  final response = await http.get(
    Uri.parse("$backendURL/api/v1/user/order/$id"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
  );
  if (response.statusCode == 200) {
    return OrderDetailResponse(
      statusCode: response.statusCode,
      orderDetail: Order.fromJson(jsonDecode(response.body)),
    );
  }
  return OrderDetailResponse(
    statusCode: response.statusCode,
    error: ApiErrorResponse.fromJson(jsonDecode(response.body)),
    orderDetail: Order.fromJson(jsonDecode(response.body)),
  );
}