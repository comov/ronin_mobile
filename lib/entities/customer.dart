class Customer {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;
  final String createdAt;
  final String modifiedAt;

  const Customer({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json["id"],
      phone: json["phone"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      createdAt: json["created_at"],
      modifiedAt: json["modified_at"],
    );
  }

  factory Customer.empty() {
    return const Customer(
      id: 0,
      phone: "",
      firstName: "",
      lastName: "",
      createdAt: "",
      modifiedAt: "",
    );
  }

  displayName() {
    if (firstName != '' && lastName != '') {
      return "$firstName $lastName";
    }
    return phone;
  }
}