import 'package:car_helper/entities/car.dart';
import 'package:car_helper/entities/customer.dart';
import 'package:car_helper/entities/driver.dart';
import 'package:car_helper/entities/employee.dart';
import 'package:car_helper/entities/photo.dart';
import 'package:car_helper/entities/service.dart';

enum OrderStatus {
  created,
  cancelled,
  pending,
  accepted,
  acceptedCar,
  onTrack,
  onCustomer,
  completed,
}

Map<int, String> orderStatusMap = {
  // Клиент создал заказ
  OrderStatus.cancelled.index: "Отменен",
  // Заказ отменен
  OrderStatus.pending.index: "В обработке",
  // Менеджер принял заказ и назначает водителя
  OrderStatus.accepted.index: "Принят",
  // Заказ назначен на водителя и водитель выполняет заказ
  OrderStatus.acceptedCar.index: "Машина у водителя",
  // Водитель принял машину у клиента
  OrderStatus.onTrack.index: "На выполнении",
  // Заказ на выполнении услуги (Сервиса)
  OrderStatus.onCustomer.index: "Машина у клиента",
  // Клиент забрал машину
  OrderStatus.completed.index: "Клиент оценил выполнение",
  // Клиент оценил выполнение заказа
  OrderStatus.created.index: "Создан",
};

class Order {
  final int id;
  final String? comment;
  final String status;
  final String? pickUpAddress;
  final DateTime? pickUpTime;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Car? car;
  final Driver? driver;
  final Customer customer;
  final Employee? employee;
  final List<Service> services;
  final List<Photo?> photos;

  const Order({
    required this.id,
    required this.comment,
    required this.pickUpAddress,
    this.pickUpTime,
    required this.status,
    required this.car,
    required this.customer,
    required this.driver,
    required this.employee,
    required this.services,
    required this.createdAt,
    required this.modifiedAt,
    required this.photos,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final services = <Service>[];

    for (final item in json["services"]) {
      services.add(
        Service(
          id: item["id"],
          title: item["title"],
          description: item["description"],
        ),
      );
    }
    final photos = <Photo>[];
    if (json["photos"] != null) {
      for (final item in json["photos"]) {
        photos.add(Photo(kind: item["kind"], imageUrl: item["image_url"]));
      }
    }

    return Order(
      id: json["id"],
      comment: json["comment"],
      status: json["status"],
      pickUpAddress: json["pick_up_address"],
      pickUpTime: DateTime.tryParse(json["pick_up_time"].toString()),
      createdAt: DateTime.parse(json["created_at"]),
      modifiedAt: DateTime.parse(json["modified_at"]),
      car: json["car"] == null ? Car.empty() : Car.fromJson(json["car"]),
      customer: json["customer"] == null
          ? Customer.empty()
          : Customer.fromJson(json["customer"]),
      driver: json["driver"] == null
          ? Driver.empty()
          : Driver.fromJson(json["driver"]),
      employee: json["employee"] == null
          ? Employee.empty()
          : Employee.fromJson(json["employee"]),
      services: services,
      photos: photos,
      // photos: json["photos"] == null ? Photo.empty() : Photo.fromJson(json["photos"]),
    );
  }
}

extension DateTimeExtension on DateTime {
  static DateTime parseUtc(String formattedDate) =>
      DateTime.parse(formattedDate);

  static DateTime? tryParseUtc(String? formattedDate) {
    if (formattedDate != null) {
      return DateTime.tryParse(formattedDate);
    }
    return null;
  }
}
