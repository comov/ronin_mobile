import 'package:car_helper/entities/order.dart';
import 'package:car_helper/resources/api_order_list.dart';
import 'package:car_helper/resources/refresh.dart';
import 'package:car_helper/screens/authorization/sign_in_screen.dart';
import 'package:car_helper/screens/order/detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DateFormat formatter = DateFormat("d MMMM yyyy, HH:mm");
late String authToken;
String refreshKey = "";

List<Order> orders = [];

Widget bottomOrders(BuildContext context) {
  return FutureBuilder<String>(
    future: loadInitialDataOrders(),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: Text("Загрузка...")),
        );
      }

      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Ошибка при загрузке приложения :("),
                Text("${snapshot.error}"),
              ],
            ),
          ),
        );
      }

      switch (snapshot.data!) {
        case "tokenNotFound":
          {
            debugPrint("authToken is empty: $authToken");
            return const SignIn();
          }
        case "tokenExpired":
          {
            debugPrint("authToken is expired: $authToken");
            return const SignIn();
          }
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text("Заказы"),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 34,
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: orders.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/order/detail",
                    arguments: OrderDetailArgs(orderId: orders[index].id),
                  );
                },
                child: Row(
                  children: [
                    Text(orders[index].id.toString()),
                    const Spacer(),
                    Text(formatter.format(orders[index].createdAt.toLocal())),
                    const Spacer(),
                    SizedBox(
                        width: 100,
                        child: Text(
                          orders[index].status,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.blue),
                        )),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      );
    },
  );
}

Future<String> loadInitialDataOrders() async {
  final pf = await SharedPreferences.getInstance();
  authToken = pf.getString("auth_token") ?? "";
  refreshKey = pf.getString("refresh_key") ?? "";
  debugPrint("orderlistFuture");


  if (authToken == "") {
    return Future.value("tokenNotFound");
  }

  final getOrderListResponse = await getOrders(authToken);
  {
    switch (getOrderListResponse.statusCode) {
      case 200:
        {
          orders = getOrderListResponse.orders;
        }
        break;
      case 401:
        {
          final refreshResponse = await refreshToken(refreshKey);
          if (refreshResponse.statusCode == 200) {
            debugPrint("orderlist case- 401-200");

            authToken = refreshResponse.auth!.token;
            refreshKey = refreshResponse.auth!.refreshKey;
            pf.setString("auth_token", authToken);
            pf.setString("refresh_key", refreshKey);
            break;
          } else {
            debugPrint(
                "refreshResponse.statusCode: ${refreshResponse.statusCode}");
            debugPrint("refreshResponse.error: ${refreshResponse.error}");
            return Future.value("tokenExpired");
          }
        }
    }
  }
  return Future.value("Ok");
}


