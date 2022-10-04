import 'package:car_helper/entities/user.dart';
import 'package:car_helper/resources/api_user_profile.dart';
import 'package:car_helper/resources/refresh.dart';
import 'package:car_helper/screens/authorization/sign_in_screen.dart';
import 'package:car_helper/screens/index/index.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckerPage extends StatefulWidget {
  const CheckerPage({Key? key}) : super(key: key);

  @override
  State<CheckerPage> createState() => _CheckerPage();
}

class _CheckerPage extends State<CheckerPage> {
  String authToken = "";
  String phoneNumber = "";
  String refreshKey = "";
  Profile? profile;
  String fireBasePushToken = "";
  String fireBaseChatToken = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          case "tokenExpired":
            {
              // const Text("Сессия устарела");
              debugPrint("authToken is expired: $authToken");
              return const SignIn();
            }
        }
        return Index(0);
      },
    );
  }

  Future<String> loadInitialData() async {
    var pf = await SharedPreferences.getInstance();

    authToken = pf.getString("auth_token") ?? "";
    phoneNumber = pf.getString("phone_number") ?? "";
    refreshKey = pf.getString("refresh_key") ?? "";
    fireBasePushToken = pf.getString("firebase_push_token") ?? "";

    if (authToken == "") {
      return Future.value("tokenNotFound");
    }

    if (fireBasePushToken != "") {
      final fireBasePushTokenResponse =
          await postFirebasePushToken(authToken, fireBasePushToken);
      switch (fireBasePushTokenResponse.statusCode) {
        case 200:
          {
            debugPrint("fireBasePushToken: $fireBasePushToken");
          }
          break;
      }
    }

    final profileResponse = await getProfile(authToken);
    switch (profileResponse.statusCode) {
      case 200:
        {
          profile = profileResponse.profile;
          final fireBaseChatTokenResponse =
              await getFirebaseChatToken(authToken);
          switch (fireBaseChatTokenResponse.statusCode) {
            case 200:
              {
                fireBaseChatToken = fireBaseChatTokenResponse.auth!.token;
                debugPrint("fireBaseChatToken: $fireBaseChatToken");
                pf.setString("firebase_chat_token", fireBaseChatToken);
                break;
              }
          }
          break;
        }
      case 401:
        {
          debugPrint(refreshKey);

          final refreshResponse = await refreshToken(refreshKey);
          if (refreshResponse.statusCode == 200) {
            authToken = refreshResponse.auth!.token;
            refreshKey = refreshResponse.auth!.refreshKey;
            pf.setString("auth_token", authToken);
            pf.setString("refresh_key", refreshKey);
            final fireBaseChatTokenResponse =
                await getFirebaseChatToken(authToken);
            switch (fireBaseChatTokenResponse.statusCode) {
              case 200:
                {
                  fireBaseChatToken = fireBaseChatTokenResponse.auth!.token;
                  debugPrint("fireBaseChatToken: $fireBaseChatToken");
                  pf.setString("firebase_chat_token", fireBaseChatToken);
                }
                break;
            }

            break;
          } else {
            debugPrint(
                "refreshResponse.statusCode: ${refreshResponse.statusCode}");
            debugPrint("refreshResponse.error: ${refreshResponse.error}");
            return Future.value("tokenExpired");
          }
        }
    }

    return Future.value("Ok");
  }
}
