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
    //TODO endpoint with FireToken
    final fireToken = "eyJhbGciOiAiUlMyNTYiLCAidHlwIjogIkpXVCIsICJraWQiOiAiYzNhZTcyMDYyODZmYmEwYTZiODIxNzllYTQ0NmFiZjE4Y2FjOGM2ZSJ9.eyJpc3MiOiAiZmlyZWJhc2UtYWRtaW5zZGsteXd6eGVAcm9uaW4tbW9iaWxlLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwgInN1YiI6ICJmaXJlYmFzZS1hZG1pbnNkay15d3p4ZUByb25pbi1tb2JpbGUuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCAiYXVkIjogImh0dHBzOi8vaWRlbnRpdHl0b29sa2l0Lmdvb2dsZWFwaXMuY29tL2dvb2dsZS5pZGVudGl0eS5pZGVudGl0eXRvb2xraXQudjEuSWRlbnRpdHlUb29sa2l0IiwgInVpZCI6ICJjdXN0b21lcjoxIiwgImlhdCI6IDE2NjQzNDc5NzYsICJleHAiOiAxNjY0MzUxNTc2fQ.B-pLC8I7BChbATqGPXux0vVY0-6WV3SQySqW9jOix_dZEKHjgTFKQ7rFMMJxzCrqNR4UcD_XGjbVDOjA8gfDok62n4jXj6mNlJ7WUrr2KtmFvNi8L5E-vHC0dYhvITi3mLkfBnVuHY8a_5P7rR3OiPDbyJZIh-xnE4mYRq1sJmqzUZKxlrXF9YyoIz7SrT8cX-_i9Dha3jZ7iXc9BLJ3DaEi-ZcPfAHLtcFOU4dR_OiG-_T_Jh2wqHWp-YK6uyRu5HUA1Y5ciHPDZjjCwvLGnYHNQAaAWZxH16AU_qJ_Y1hcj5jW7Y0HFFoQh05C9vCCq9A0Q7J9VHAf29YxXq9qRQ";
    pf.setString("fire_token", fireToken);


    if (authToken == "") {
      return Future.value("tokenNotFound");
    }

    final profileResponse = await getProfile(authToken);
    switch (profileResponse.statusCode) {
      case 200:
        {
          profile = profileResponse.profile;
        }
        break;
      case 401:
        {
          debugPrint(refreshKey);

          final refreshResponse = await refreshToken(refreshKey);
          if (refreshResponse.statusCode == 200) {
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

    return Future.value("Ok");
  }
}
