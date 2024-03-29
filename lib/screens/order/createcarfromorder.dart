import 'dart:async';

import 'package:car_helper/entities/car.dart';
import 'package:car_helper/resources/api_user_profile.dart';
import 'package:car_helper/screens/index/services.dart';
import 'package:car_helper/screens/order/create.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCarFromOrderArgs {
  Map<int, SelectedService> servicesMaps = {};

  CreateCarFromOrderArgs({required this.servicesMaps});
}

class CreateCarFromOrder extends StatefulWidget {
  const CreateCarFromOrder({Key? key}) : super(key: key);

  @override
  State<CreateCarFromOrder> createState() => _CreateCarFromOrderState();
}

class _CreateCarFromOrderState extends State<CreateCarFromOrder> {
  String authToken = "";
  List<Car> carList = [];

  String brand = "";
  String model = "";
  int? year;
  String yearString = "выберите год";
  String vin = "";
  String plateNumber = "";


  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    final formKey = GlobalKey<FormState>();

    final args = ModalRoute.of(context)!.settings.arguments as CreateCarFromOrderArgs;

    final services = args.servicesMaps;

    return FutureBuilder<String>(
      future: loadFromStorage(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Scaffold(
          appBar: AppBar(
            // title: const Text("Добавление авто"),
            // titleTextStyle: const TextStyle(
            //   color: Colors.black,
            //   fontWeight: FontWeight.bold,
            //   fontSize: 20,
            // ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Добавление авто",
                    style: TextStyle(fontSize: 34),
                  ),
                  Flex(direction: Axis.horizontal, children: [
                    Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (text) => {brand = text},
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: "Марка авто",
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Поле не может быть пустым";
                                }

                                if (value.length >= 15) {
                                  return "Поле может быть больше 15 символов";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              onChanged: (text) => {model = text},
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: "Модель авто",
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Поле не может быть пустым";
                                }

                                if (value.length >= 15) {
                                  return "Поле может быть больше 15 символов";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              onChanged: (text) => {plateNumber = text},
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: "Гос. Номер авто",
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Поле не может быть пустым";
                                }

                                if (value.length >= 12) {
                                  return "Поле может быть больше 11 символов";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              onChanged: (text) => {vin = text},
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: "VIN авто",
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.length >= 18) {
                                  return "Не больше 18 символов";
                                }
                                return null;
                              },
                            ),
                            TextFormField(onChanged: (text) => {year = int.parse(text)},

                              autofocus: true,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Год авто",
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.length >= 5) {
                                  return "Поле может быть больше 4 символов";
                                }
                                 if (value.length <4) {
                                  return "Поле может быть меньше 4 символов";
                                }

                                return null;
                              },
                            ),
                          ],
                        )),
                  ]),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        _createCar().then(
                              (value) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Результат'),
                                content: SizedBox(
                                  height: 80,
                                  child: Column(
                                    children: [
                                      if (value == 200)
                                        const Text("Авто успешно добавлено")
                                      else if (value == 403)
                                        const Text("Превышен лимит авто")
                                      else
                                        const Text(
                                            "Произошла ошибка добавления авто")
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Назад')),
                                  if (value == 200)
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamedAndRemoveUntil("/order/new", (route) => false,  arguments: OrderCreateArgs(
                                            servicesMaps: services,
                                          ),);

                                        },
                                        child: const Text('К оформлению заказа'))
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: const Text("Добавить авто"),
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

    return Future.value("Ok");
  }

  Future<int> _createCar() async {
    final response =
    await createCar(authToken, brand, model, year ?? 0, vin, plateNumber);
    switch (response.statusCode) {
      case 200:
        {
          final car = response.cars;
          debugPrint("Авто было добавлено! Card.id: $car");
          break;
        }
      case 403:
        {
          debugPrint("У Вас превышен лимит авто: ${response.statusCode}");
          break;
        }
      default:
        {
          debugPrint("Ошибка при создании Авто: ${response.statusCode}");
          debugPrint("response.error!.error=${response.error!.error}");
          debugPrint("response.error!.message=${response.error!.message}");
          break;
        }
    }

    return Future.value(response.statusCode);
  }
}
