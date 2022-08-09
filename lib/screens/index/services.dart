import 'dart:async';

import 'package:car_helper/entities/category.dart';
import 'package:car_helper/entities/service.dart';
import 'package:car_helper/resources/api_categories.dart';
import 'package:car_helper/screens/authorization/sign_in_screen.dart';
import 'package:car_helper/screens/order/create.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

String authToken = "";
String phoneNumber = "";
String refreshKey = "";

List<Category> categories = [];

class SelectedService {
  var checked = false;
  final Service service;

  SelectedService({required this.service});
}

final Map<int, SelectedService> servicesMap = {};

Widget renderOrders(BuildContext context) {
  final selectedServiceController = SelectedServiceController();
  selectedServiceController.setMap(servicesMap);

  final controller = Get.put(selectedServiceController);

  return FutureBuilder<String>(
    future: loadInitialData(),
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
        case "":
          {
            debugPrint("authToken is expired: $authToken");
            return const SignIn();
          }
      }
      final categoriesBlock = GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.65,
        children: List.generate(categories.length, (index) {
          return TextButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(left: 4, right: 4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  width: double.infinity,
                  height: 100,
                  // padding: EdgeInsets.all(32),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      categories[index].title,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () async {
              _showModalBottomSheet(
                context,
                servicesMap,
                categories[index].services,
              );
            },
          );
        }),
      );

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: categoriesBlock,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GetBuilder<SelectedServiceController>(
                  init: selectedServiceController,
                  builder: (value) => getSelectedServicesCard(
                    context,
                    controller,
                    value,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget getSelectedServicesCard(context, controller, value) {
  List<Widget> children = [];
  if (value.isEmpty()) {
    children.add(
      const ListTile(
        title: Text("Выберите категорию и тип услуги"),
        subtitle: Text(
          "Вы можете выбрать услуги с разных категорий и"
          " оформить заказ на удобное вам время",
        ),
      ),
    );
  } else {
    List<Widget> services = [];

    for (var item in value.servicesMap.values.toList()) {
      if (item.checked == true) {
        final serviceItem = CheckboxListTile(
          title: Text(item.service.title),
          value: item.checked,
          onChanged: (bool? value) {
            controller.checked(item.service.id, value);
          },
        );
        services.add(serviceItem);
      }
    }

    children.add(
      const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text("Выбранные услуги"),
        ),
      ),
    );
    children.add(
      Container(
        constraints: const BoxConstraints(maxHeight: 260),
        // height: 380,
        child: SingleChildScrollView(
          child: Column(
            children: services,
          ),
        ),
      ),
    );
    children.add(
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          child: const Text("Продолжить"),
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/order/new",
              arguments: OrderCreateArgs(
                servicesMaps: value.servicesMap,
              ),
            );
          },
        ),
      ),
    );
  }

  return Column(
    children: children,
  );
}

void _showModalBottomSheet(
  BuildContext context,
  Map<int, SelectedService> servicesMap,
  List<Service> services,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return ListOfServices(
        servicesMap: servicesMap,
        services: services,
      );
    },
  );
}

Future<String> loadInitialData() async {
  final pf = await SharedPreferences.getInstance();
  var authToken = pf.getString("auth_token") ?? "";

  final categoriesResponse = await getCategories(authToken);
  switch (categoriesResponse.statusCode) {
    case 200:
      {
        categories = categoriesResponse.categories;
      }
      break;
    case 401:
      {
        return Future.value("tokenExpired");
      }
  }

  for (final category in categories) {
    for (final service in category.services) {
      servicesMap[service.id] = SelectedService(service: service);
    }
  }

  return Future.value("Ok");
}

class SelectedServiceController extends GetxController {
  String emptyData = "Выберите сервисы";

  late final Map<int, SelectedService> servicesMap;

  void setMap(Map<int, SelectedService> map) {
    servicesMap = map;
  }

  void checked(int serviceId, bool? value) {
    servicesMap[serviceId]?.checked = value!;
    update();
  }

  bool isEmpty() {
    for (final service in servicesMap.values.toList()) {
      if (service.checked == true) {
        return false;
      }
    }
    return true;
  }
}

class ListOfServices extends StatefulWidget {
  const ListOfServices({
    Key? key,
    required this.servicesMap,
    required this.services,
  }) : super(key: key);
  final Map<int, SelectedService> servicesMap;
  final List<Service> services;

  @override
  State<ListOfServices> createState() => _ListOfServicesState(
        servicesMap: servicesMap,
        services: services,
      );
}

class _ListOfServicesState extends State<ListOfServices> {
  final Map<int, SelectedService> servicesMap;
  final List<Service> services;

  _ListOfServicesState({
    required this.servicesMap,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelectedServiceController());
    return SizedBox(
      height: 500,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(services[index].title),
                  value: servicesMap[services[index].id]?.checked,
                  onChanged: (bool? value) {
                    setState(() {
                      controller.checked(services[index].id, value!);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}