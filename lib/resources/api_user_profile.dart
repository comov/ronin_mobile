import 'dart:convert';

import 'package:car_helper/entities/api.dart';
import 'package:car_helper/entities/car.dart';
import 'package:car_helper/entities/user.dart';
import 'package:car_helper/main.dart';
import 'package:http/http.dart' as http;

class ProfileResponse {
  final int statusCode;

  final Profile? profile;
  final ApiErrorResponse? error;

  const ProfileResponse({required this.statusCode, this.profile, this.error});
}

class FireAuthResponse {
  final int statusCode;
  final FireChatAuthData? auth;
  final ApiErrorResponse? error;

  const FireAuthResponse({required this.statusCode, this.auth, this.error});
}

class FirePushResponse {
  final int statusCode;
  final ApiErrorResponse? error;

  const FirePushResponse({required this.statusCode, this.error});
}

Future<ProfileResponse> getProfile(String authToken) async {
  final response = await http.get(
    Uri.parse("$backendURL/api/v1/user/profile"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
  );
  if (response.statusCode == 200) {
    return ProfileResponse(
      statusCode: response.statusCode,
      profile: Profile.fromJson(jsonDecode(response.body)),
    );
  }
  return ProfileResponse(
    statusCode: response.statusCode,
    error: ApiErrorResponse.fromJson(jsonDecode(response.body)),
  );
}

Future<FireAuthResponse> getFirebaseChatToken(String authToken) async {
  final response = await http.get(
    Uri.parse("$backendURL/api/v1/user/profile/firebase/token"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
  );
  if (response.statusCode == 200) {
    return FireAuthResponse(
      statusCode: response.statusCode,
      auth: FireChatAuthData.fromJson(jsonDecode(response.body)),
    );
  }
  return FireAuthResponse(
    statusCode: response.statusCode,
    error: ApiErrorResponse.fromJson(jsonDecode(response.body)),
  );
}

Future<FirePushResponse> postFirebasePushToken(
    String authToken, String fireBasePushToken) async {
  final response = await http.post(
    Uri.parse(
        "$backendURL/api/v1/user/profile/firebase?fb_token=$fireBasePushToken"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
  );
  if (response.statusCode == 200) {
    return FirePushResponse(
      statusCode: response.statusCode,
    );
  }
  return FirePushResponse(
    statusCode: response.statusCode,
    error: ApiErrorResponse.fromJson(jsonDecode(response.body)),
  );
}

Future<ProfileResponse> editProfile(
    String authToken, String firstName, String lastName) async {
  final response = await http.put(
    Uri.parse("$backendURL/api/v1/user/profile"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
    body: jsonEncode({"first_name": firstName, "last_name": lastName}),
  );
  if (response.statusCode == 200) {
    return ProfileResponse(
      statusCode: response.statusCode,
      profile: Profile.fromJson(jsonDecode(response.body)),
    );
  }
  return ProfileResponse(
    statusCode: response.statusCode,
    error: ApiErrorResponse.fromJson(jsonDecode(response.body)),
  );
}

Future<ProfileResponse> deleteProfile(String authToken) async {
  final response = await http.delete(
    Uri.parse("$backendURL/api/v1/user/profile"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
  );
  if (response.statusCode == 200) {
    return ProfileResponse(
      statusCode: response.statusCode,
      // profile: Profile.fromJson(jsonDecode(response.body)),
    );
  }
  return ProfileResponse(
    statusCode: response.statusCode,
    // error: ApiErrorResponse.fromJson(jsonDecode(response.body)),
  );
}

class CarListResponse {
  final int statusCode;

  final List<Car> cars;
  final ApiErrorResponse? error;

  const CarListResponse({
    required this.statusCode,
    required this.cars,
    this.error,
  });

  parseJson(List<dynamic> jsonList) {
    for (var item in jsonList) {
      cars.add(Car.fromJson(item));
    }
  }
}

Future<CarListResponse> getCustomerCars(String authToken) async {
  final response = await http.get(
    Uri.parse("$backendURL/api/v1/user/cars"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
  );
  final res = CarListResponse(statusCode: response.statusCode, cars: []);
  if (response.statusCode == 200) {
    res.parseJson(jsonDecode(response.body));
  }
  return res;
}

Future<CarListResponse> createCar(String authToken, String brand, String model,
    int year, String vin, String plateNumber) async {
  final response = await http.post(
    Uri.parse("$backendURL/api/v1/user/cars"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
    body: jsonEncode({
      "brand": brand,
      "model": model,
      "year": year,
      "plate_number": plateNumber,
      "vin": vin
    }),
  );
  final res = CarListResponse(statusCode: response.statusCode, cars: []);
  if (response.statusCode == 200) {
    res.parseJson(jsonDecode(response.body));
  }
  return res;
}

Future<CarListResponse> editCar(String authToken, int id, String brand,
    String model, int year, String plateNumber, String vin) async {
  final response = await http.put(
    Uri.parse("$backendURL/api/v1/user/cars/$id"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
    body: jsonEncode({
      "brand": brand,
      "model": model,
      "year": year,
      "plate_number": plateNumber,
      "vin": vin
    }),
  );
  final res = CarListResponse(statusCode: response.statusCode, cars: []);
  if (response.statusCode == 200) {
    res.parseJson(jsonDecode(response.body));
  }
  return res;
}

Future<CarListResponse> deleteCar(String authToken, int id) async {
  final response = await http.delete(
    Uri.parse("$backendURL/api/v1/user/cars/$id"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $authToken",
    },
  );
  final res = CarListResponse(statusCode: response.statusCode, cars: []);
  if (response.statusCode == 200) {
    // res.parseJson(jsonDecode(response.body));
    // res = response.statusCode;
  }
  return res;
}
