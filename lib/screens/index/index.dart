// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_null_comparison

import 'package:car_helper/entities/push_notifications.dart';
import 'package:car_helper/screens/index/main.dart';
import 'package:car_helper/screens/index/orders.dart';
import 'package:car_helper/screens/index/profile.dart';
import 'package:car_helper/screens/index/services.dart';
import 'package:car_helper/screens/notification_badge.dart';
import 'package:car_helper/screens/order/detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

const String homeIcon = "assets/images/icon/TabBarMain.svg";
const String servicesIcon = "assets/images/icon/TabBarServices.svg";
const String ordersIcon = "assets/images/icon/TabBarOrders.svg";
const String profileIcon = "assets/images/icon/TabBarProfile.svg";

class HomeArgs {
  int initialState;

  HomeArgs({required this.initialState});
}

// ignore: must_be_immutable
class Index extends StatefulWidget {
  int selectedBottom;

  Index(this.selectedBottom, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<Index> createState() => _IndexState(selectedBottom);
}

class _IndexState extends State<Index>
    with MainState, SingleTickerProviderStateMixin {
  int selectedBottom = 0;
  Map<int, List> widgetOptions = {};
  late TabController _tabController;

  _IndexState(this.selectedBottom);

  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  void requestAndRegisterNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();
    var pf = await SharedPreferences.getInstance();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      String? fireBasePushToken = await _messaging.getToken();
      pf.setString("firebase_push_token", fireBasePushToken!);


      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });
        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: const Duration(seconds: 2),
          );
        }
      });
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    final fireBaseChatToken = pf.getString("firebase_chat_token") ?? "";
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCustomToken(fireBaseChatToken);
      print("Sign-in successful.");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-custom-token":
          print("The supplied token is not a Firebase custom auth token.");
          break;
        case "custom-token-mismatch":
          print("The supplied token is for a different Firebase project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    debugPrint('setupInteractedMessage');

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    final routeFromNotification = message.data["screen"];
    // final int orderFromNotification = message.data["order"];
    debugPrint('routeFromNotification - $routeFromNotification');

    if (routeFromNotification != 0) {
      Future.delayed(const Duration(milliseconds: 1000), () async {
        Navigator.of(context).pushNamed(
          "/order/detail",
          arguments: OrderDetailArgs(orderId: int.parse(routeFromNotification)),
        );
      });
    } else {
      debugPrint('could not find the route');
    }
  }

  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TexInput.hide');
    requestAndRegisterNotification();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });
    _totalNotifications = 0;

    super.initState();
    setupInteractedMessage();

    Stream<RemoteMessage> _stream = FirebaseMessaging.onMessageOpenedApp;
    _stream.listen((RemoteMessage event) async {
      if (event.data != null) {
        final routeFromNotification = event.data["screen"];

        await Navigator.of(context).pushNamed(
          "/order/detail",
          arguments: OrderDetailArgs(orderId: int.parse(routeFromNotification)),
        );
      }
    });

    widgetOptions = {
      0: ["Главная", renderMain],
      1: ["Услуги", renderOrders],
      2: ["Заказы", bottomOrders],
      3: ["Профиль", bottomProfile],
    };
    _tabController = TabController(length: widgetOptions.length, vsync: this);
    _tabController.index = selectedBottom;
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedBottom = _tabController.index;
        });
      }
    });

    return DefaultTabController(
      length: widgetOptions.length,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: <Widget>[
            renderMain(context),
            renderOrders(context),
            bottomOrders(context),
            bottomProfile(context),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            padding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 10,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
            ),
            tabs: [
              Tab(
                icon: SvgPicture.asset(homeIcon,
                    color: selectedBottom == 0 ? Colors.black : Colors.grey),
                text: 'Главная',
              ),
              Tab(
                icon: SvgPicture.asset(
                  servicesIcon,
                  color: selectedBottom == 1 ? Colors.black : Colors.grey,
                ),
                text: 'Новый заказ',
              ),
              Tab(
                icon: SvgPicture.asset(ordersIcon,
                    color: selectedBottom == 2 ? Colors.black : Colors.grey),
                text: 'Заказы',
              ),
              Tab(
                icon: SvgPicture.asset(profileIcon,
                    color: selectedBottom == 3 ? Colors.black : Colors.grey),
                text: 'Профиль',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
