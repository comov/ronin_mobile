import 'package:car_helper/entities/user.dart';
import 'package:flutter/material.dart';

class UserEditArs {
  final Profile? profile;

  UserEditArs({required this.profile});
}

class UserEdit extends StatefulWidget {
  const UserEdit({Key? key}) : super(key: key);

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as UserEditArs;
    final profile = args.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактирование профиля"),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 5),
                          Text("Ваш номер телефона: ${profile?.phone}"),
                          TextField(
                            onChanged: (val) {
                              profile?.firstName = val;
                            },
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'Введите имя ',
                            ),
                          ),
                          TextField(
                            onChanged: (val) {
                              profile?.lastName = val;
                            },
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'Введите фамилию',
                            ),
                          ),
                          const SizedBox(height: 5),
                        ]),
                  ),
                ),
              ),
            ],
          ),
          Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[Text("Добавить новое авто")],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Сохранить"),
            ),
          )
        ],
      ),
    );
  }

  Future<String> loadInitialData() async {
    return Future.value("Ok");
  }
}
