import 'dart:async';

import 'package:car_helper/entities/car.dart';
import 'package:car_helper/entities/order.dart';
import 'package:car_helper/resources/api_order_create.dart';
import 'package:car_helper/resources/api_user_profile.dart';
import 'package:car_helper/screens/index/index.dart';
import 'package:car_helper/screens/index/services.dart';
import 'package:car_helper/screens/order/createcarfromorder.dart';
import 'package:car_helper/screens/order/detail.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';

class OrderCreateArgs {
  Map<int, SelectedService> servicesMaps = {};

  OrderCreateArgs({required this.servicesMaps});
}

class OrderNew extends StatefulWidget {
  const OrderNew({Key? key}) : super(key: key);

  @override
  State<OrderNew> createState() => _OrderNewState();
}

class _OrderNewState extends State<OrderNew> {
  String authToken = "";
  String customerComment = "";
  String pickUpAddress = "";
  List<Car>? carList = [];
  DateTime? pickUpTime;
  DateTime? pickUpTimeToSrv;

  int selectItemId = 0;
  bool _clicked = false;

  // int value = 0;

  int selectedIndex1 = 0;
  String? selectItem = "";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OrderCreateArgs;

    final services = args.servicesMaps;

    FocusManager.instance.primaryFocus?.unfocus();
    final formKey = GlobalKey<FormState>();

    return FutureBuilder<String>(
      future: loadFromStorage(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding:
                const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
            child: Form(
              key: formKey,
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Форма заказа",
                    style: TextStyle(fontSize: 34),
                  ),
                  const Text(
                    "Все заявки обрабатываются в течении 2х часов, начинаем выполнять на следующий день, чтобы заранее могли забронировать очередь в СТО",
                    style: TextStyle(fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ExpansionTileCard(
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
                              for (var item in servicesMap.values.toList())
                                if (item.checked == true)
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(item.service.title)),
                              // const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8.0),
                    child: Column(
                      children: [
                        if (carList!.isEmpty)
                          carIsEmpty(services)
                        else
                          Row(
                            children: [
                              const Text("Выберите авто"),
                              const Spacer(),
                              DropdownButton(
                                  value: selectItem,
                                  items: carList?.map((car) {
                                    return DropdownMenuItem(
                                      value: car.plateNumber,
                                      child: Text(car.plateNumber),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      var item = newValue!;
                                      selectItem = newValue;
                                      debugPrint("item= $item");
                                    });
                                  })
                            ],
                          )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Адрес откуда забрать авто:",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextFormField(
                      onChanged: (text) => {pickUpAddress = text},
                      // autofocus: true,
                      keyboardType: TextInputType.text,
                      initialValue: pickUpAddress,
                      decoration: InputDecoration(
                        hintText: "Название улицы, номер дома",
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.length >= 50) {
                          return "Поле может быть больше 50 символов";
                        }
                        return null;
                      },
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "Удобное для Вас время:",
                        style: TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime.now(),
                                maxTime:
                                    DateTime.now().add(const Duration(days: 7)),
                                onChanged: (date) {}, onConfirm: (date) {
                              setState(() {
                                pickUpTime = date.toUtc();
                                pickUpTimeToSrv = date.toUtc();
                              });
                            },
                                currentTime: pickUpTime?.toLocal(),
                                locale: LocaleType.ru);
                          },
                          child: Text(
                            pickUpTime == null
                                ? "Выбрать время"
                                : DateFormat("dd-MMM-yyyy").format(pickUpTime!),
                            style: const TextStyle(color: Colors.blue),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      "Пожелания/Комментарии",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  TextFormField(
                    onChanged: (text) => {customerComment = text},
                    // autofocus: true,
                    keyboardType: TextInputType.text,
                    initialValue: customerComment,
                    decoration: InputDecoration(
                      hintText:
                          "Пожелания и предложения",
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.length >= 50) {
                        return "Поле может быть больше 50 символов";
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _clicked
                        ? null
                        : () {
                      setState(() => _clicked = true);

                      if (formKey.currentState!.validate()) {
                              final List<int> selectedServices = [
                                for (final item in services.values)
                                  if (item.checked == true) item.service.id
                              ];

                              _createOrder(selectedServices).then((order) {
                                if (order != null) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Index(2)),
                                      (Route<dynamic> route) => false);

                                  Navigator.pushNamed(
                                    context,
                                    "/order/detail",
                                    arguments: OrderDetailArgs(orderId: order.id),
                                  );
                                } else {
                                  setState(() => _clicked = false);
                                }
                              });
                            }
                          },
                    child: const Text("Оформить заказ"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> loadFromStorage() async {
    final pf = await SharedPreferences.getInstance();
    authToken = pf.getString("auth_token") ?? "";

    final getCarListResponse = await getCustomerCars(authToken);
    carList = getCarListResponse.cars;
    debugPrint("again");

    if (selectItem!.isEmpty) {
      if (carList!.isNotEmpty) {
        selectItem = carList?.first.plateNumber;
      }
    }

    return Future.value("Ok");
  }

  Future<Order?> _createOrder(List<int> checkedServices) async {
    debugPrint("car - $selectItem");
    // ignore: prefer_typing_uninitialized_variables
    var car;

    if (carList!.isNotEmpty) {
      var item = carList?.where((element) => element.plateNumber == selectItem);
      for (var cars in item!) {
        car = cars.id;
      }
    }
    final response = await createOrder(
        authToken,
        checkedServices,
        customerComment,
        pickUpAddress,
        pickUpTimeToSrv?.toIso8601String(),
        car ?? 0);

    switch (response.statusCode) {
      case 200:
        {
          final order = response.order!;
          debugPrint("Заказ был создан! Order: ${order.id}");
          break;
        }
      default:
        {
          debugPrint("Ошибка при создании Заказа: ${response.statusCode}");
          debugPrint("response.error!.error=${response.error!.error}");
          debugPrint("response.error!.message=${response.error!.message}");
          break;
        }
    }

    return Future.value(response.order);
  }

  Widget carIsEmpty(Map<int, SelectedService> services) {
    return Row(
      children: [
        const Text("У Вас нету добавленных авто, можете добавить"),
        TextButton(
            onPressed: () {
              //TO DO need to add check if customer has 3 cars in profile
              Navigator.pushNamed(
                context,
                "/order/create_car_from_order",
                arguments: CreateCarFromOrderArgs(
                  servicesMaps: services,
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text("тут")),
      ],
    );
  }
}
