import 'package:car_helper/screens/authorization/auth_screen.dart';
import 'package:car_helper/screens/authorization/sign_in_screen.dart';
import 'package:car_helper/screens/debug_page_screen.dart';
import 'package:car_helper/screens/index/checkerpage.dart';
import 'package:car_helper/screens/index/index.dart';
import 'package:car_helper/screens/order/create.dart';
import 'package:car_helper/screens/order/createcarfromorder.dart';
import 'package:car_helper/screens/order/detail.dart';
import 'package:car_helper/screens/order/more_detail.dart';
import 'package:car_helper/screens/user/create_car.dart';
import 'package:car_helper/screens/user/edit_car.dart';
import 'package:car_helper/screens/user/edit_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const sentryDSN =
    "https://8198951336c94b3cba51cd09a46dbac2@o1348955.ingest.sentry.io/6655166";
const backendURL = "https://stage.i-10.win";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDSN;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
  // or define SENTRY_DSN via Dart environment variable (--dart-define)
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
      title: "CarHelpers",
      initialRoute: "/checkerPage",
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        cardTheme: CardTheme(
          shadowColor: const Color.fromRGBO(0, 0, 0, 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.black),
          fillColor: MaterialStateProperty.all(Colors.black),
          side: const BorderSide(width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          fillColor: Colors.black,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        textTheme: const TextTheme(
          labelSmall: TextStyle(color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
          actionsIconTheme: IconThemeData(color: Colors.black, opacity: 10.0),
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 34,
          ),
          toolbarHeight: 35,
        ),
      ),
      routes: {
        "/index": (BuildContext context) => Index(0),
        "/checkerPage": (BuildContext context) => const CheckerPage(),
        "/signin": (BuildContext context) => const SignIn(),
        "/auth": (BuildContext context) => const Auth(),
        "/order/new": (BuildContext context) => const OrderNew(),
        "/order/create_car_from_order": (BuildContext context) =>
            const CreateCarFromOrder(),
        "/order/detail": (BuildContext context) => const OrderDetail(),
        // "/order/chat": (BuildContext context) => const ChatPage(room: "33",),
        "/order/more_detail": (BuildContext context) => const MoreOrderDetail(),
        "/user/edit_profile": (BuildContext context) => const UserEdit(),
        "/user/create_car": (BuildContext context) => const CreateCar(),
        "/user/edit_car": (BuildContext context) => const EditCar(),
        "/debug": (BuildContext context) => const DebugPage(),
      },
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
    ));
  }
}
