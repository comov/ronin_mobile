// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:car_helper/entities/customer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'message.dart';

class ChatPage extends StatefulWidget {
  String orderId;
  Customer customer;

  ChatPage({super.key, required this.orderId, required this.customer});

  @override
  _ChatPageState createState() =>
      _ChatPageState(orderId: orderId, customer: customer);
}

class _ChatPageState extends State<ChatPage> {
  String orderId;
  Customer customer;

  _ChatPageState({required this.orderId, required this.customer});

  final fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Заказ $orderId',
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.79,
                child: Messages(orderId: orderId, customer: customer),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: message,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.purple[100],
                        hintText: 'Сообщение...',
                        enabled: true,
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (value) {
                        message.text = value!;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (message.text.isNotEmpty) {
                        fs
                            .collection('rooms')
                            .doc('order_$orderId')
                            .collection("messages")
                            .doc()
                            .set({
                          'text': message.text.trim(),
                          'timestamp': DateTime.now(),
                          'name': customer.displayName(),
                          'uid': "customer:${customer.id}"
                        });

                        message.clear();
                      }
                    },
                    icon: const Icon(Icons.send_sharp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
