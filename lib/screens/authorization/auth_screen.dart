import 'dart:async';

import 'package:car_helper/resources/auth.dart';
import 'package:car_helper/resources/signin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  var otpCode = "";
  String phoneNumber = "";
  late Timer _timer;
  int _start = 30;
  bool validate = false;
  TextEditingController textEditingController = TextEditingController();

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    loadFromStorage();

    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  "Вход",
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontFamily: '.SF Pro Display'),
                ),
                const Text(
                  "Введите OTP код",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: '.SF Pro Text'),
                ),
                TextFormField(
                  onChanged: (text) => {otpCode = text},
                  autofocus: true,
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    errorText: validate ? 'Введён не верный  OTP код' : null,
                    // labelText: "Код подтверджения из СМС",
                    labelStyle: const TextStyle(
                        fontFamily: '.SF Pro Text', color: Colors.black),
                    hintText: "0000",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Код подтверджения не может быть пустым";
                    }

                    if (value.length != 4) {
                      return "Код подтверджения должен быть из 4-х цифр";
                    }

                    return null;
                  },
                ),
                const Spacer(),
                const Text("Не пришёл код?",
                    style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 13,
                        color: Colors.grey)),
                _start != 0
                    ? Row(
                        children: [
                          const Text(
                            "Запросить код повторно через",
                            style: TextStyle(
                                fontFamily: '.SF Pro Text',
                                fontSize: 13,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            _start.toString(),
                            style: const TextStyle(
                                fontFamily: '.SF Pro Text',
                                fontSize: 13,
                                color: Colors.grey),
                          )
                        ],
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            _start = 30;
                            startTimer();
                            singInCallBack();
                          });
                        },
                        child: const Text("Запросить код повторно"),
                      ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        authCallBack().then((value) {
                          if (value == 200) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              "/checkerPage",
                              (route) => false,
                            );
                          } else {
                            setState(() {
                              validate = true;
                              // startTimer();
                            });
                          }
                        });
                      }
                    },
                    child: const Text("Продолжить"),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Future<String> loadFromStorage() async {
    final pf = await SharedPreferences.getInstance();
    phoneNumber = pf.getString("phone_number") ?? "";
    return Future.value("Ok");
  }

  Future<String> saveAuthData(String token, String refreshKey) async {
    final pf = await SharedPreferences.getInstance();
    pf.setString("auth_token", token);
    pf.setString("refresh_key", refreshKey);
    return Future.value("Ok");
  }

  void singInCallBack() async {
    final response = await sigIn(phoneNumber);
    switch (response.statusCode) {
      case 200:
        {
          break;
        }
      default:
        {
          debugPrint("Ошибка при авторизации: ${response.statusCode}");
          debugPrint("response.error!.error=${response.error!.error}");
          debugPrint("response.error!.message=${response.error!.message}");
          break;
        }
    }
  }

  Future<int> authCallBack() async {
    final response = await auth(phoneNumber, otpCode);
    switch (response.statusCode) {
      case 200:
        {
          saveAuthData(response.auth!.token, response.auth!.refreshKey);
          break;
        }
      default:
        {
          debugPrint("Ошибка при авторизации: ${response.statusCode}");
          debugPrint("response.error!.error=${response.error!.error}");
          debugPrint("response.error!.message=${response.error!.message}");
          break;
        }
    }
    return Future.value(response.statusCode);
  }
}
