import 'package:car_helper/entities/order.dart';
import 'package:car_helper/resources/refresh.dart';
import 'package:car_helper/screens/authorization/auth_screen.dart';
import 'package:car_helper/screens/order/more_detail.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:car_helper/resources/api_order_detail.dart';

class OrderDetailArgs {
  final int orderId;

  OrderDetailArgs({required this.orderId});
}

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key}) : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  String authToken = "";
  String refreshKey = "";
  late Order order;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OrderDetailArgs;
    final orderId = args.orderId;
    final DateFormat formatter = DateFormat("d MMMM yyyy, HH:mm");
    StepperType stepperType = StepperType.vertical;

    currentState() {
      int step = 0;
      switch (order.status) {
        case "Создан":
          {
            step = 0;
            break;
          }
        case "Обрабатывается":
          {
            step = 1;
            break;
          }
        case "Ожидает исполнения":
          {
            step = 2;
            break;
          }
        case "Выполняется":
          {
            step = 3;
            break;
          }
        case "Выполнен":
          {
            step = 4;
            break;
          }
      }
      return step;
    }

    return FutureBuilder<String>(
        future: loadInitialDataOrderDetail(orderId),
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
                return const Auth();
              }
            case "tokenExpired":
              {
                debugPrint("authToken is expired: $authToken");
                return const Auth();
              }
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: order.car?.plateNumber != ""
                        ? Text("${order.car?.plateNumber}")
                        : const Text("Гос.номер"),
                  ),
                ],
              ),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text("ID заявки: ${order.id}"),
                  Text(
                      "Заявка создана: ${formatter.format(order.createdAt.toLocal())}"),
                  Text(
                      "Заявка обновлена: ${formatter.format(order.modifiedAt.toLocal())}"),
                  Text("Статус: ${order.status}"),
                  const Divider(),
                  ExpansionTileCard(
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: const Color.fromRGBO(0, 0, 0, 0.5),
                    title: const Text('Выбранные услуги'),
                    children: <Widget>[
                      const Divider(
                        thickness: 1.0,
                        height: 1.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            for (var item in order.services)
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(item.title)),
                            // const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Stepper(
                      type: stepperType,
                      physics: const ScrollPhysics(),
                      currentStep: currentState(),
                      // onStepTapped: (step) => tapped(step),
                      // onStepContinue: continued,
                      // onStepCancel: cancel,
                      controlsBuilder:
                          (BuildContext context, ControlsDetails controls) {
                        return Row(
                          children: const [
                            // Container()
                          ],
                        );
                      },
                      steps: <Step>[
                        Step(
                            title: const Text("Создан"),
                            content: Column(
                              children: const [
                                Text("тут время когда перешло на этот статус")
                              ],
                            ),
                            isActive: order.status == "Создан",
                            state: order.status == "Создан"
                                ? StepState.complete
                                : StepState.disabled),
                        Step(
                            title: const Text("Обрабатывается"),
                            content: Column(
                              children: const [
                                Text("тут время когда перешло на этот статус")
                              ],
                            ),
                            isActive: order.status == "Обрабатывается",
                            state: order.status == "Обрабатывается"
                                ? StepState.complete
                                : StepState.disabled),
                        Step(
                            title: const Text("Ожидает исполнения"),
                            content: Column(
                              children: const [
                                Text("тут время когда перешло на этот статус")
                              ],
                            ),
                            isActive: order.status == "Ожидает исполнения",
                            state: order.status == "Ожидает исполнения"
                                ? StepState.complete
                                : StepState.disabled),
                        Step(
                            title: const Text("Выполняется"),
                            content: Column(
                              children: const [
                                Text("тут время когда перешло на этот статус")
                              ],
                            ),
                            isActive: order.status == "Выполняется",
                            state: order.status == "Выполняется"
                                ? StepState.complete
                                : StepState.disabled),
                        Step(
                            title: const Text("Выполнен"),
                            content: Column(
                              children: const [
                                Text("тут время когда перешло на этот статус")
                              ],
                            ),
                            isActive: order.status == "Выполнен",
                            state: order.status == "Выполнен"
                                ? StepState.complete
                                : StepState.disabled),
                      ]),
                  const Divider(),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/order/more_detail",
                            arguments: MoreOrderDetailArgs(order: order));
                      },
                      child: const Text("Подробнее")),
                  const TextButton(onPressed: null, child: Text("Чат заявки"))
                ],
              ),
            ),
          );
        });
  }

  Future<String> loadInitialDataOrderDetail(int orderId) async {
    final pf = await SharedPreferences.getInstance();
    authToken = pf.getString("auth_token") ?? "";
    refreshKey = pf.getString("refresh_key") ?? "";
    debugPrint("orderDetailFuture");

    if (authToken == "") {
      return Future.value("tokenNotFound");
    }

    final getOrderDetailResponse = await getOrderDetail(authToken, orderId);
    {
      switch (getOrderDetailResponse.statusCode) {
        case 200:
          {
            order = getOrderDetailResponse.orderDetail;
          }
          break;
        case 401:
          {
            final refreshResponse = await refreshToken(refreshKey);
            if (refreshResponse.statusCode == 200) {
              debugPrint("orderDetailCase- 401-200");

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
}
