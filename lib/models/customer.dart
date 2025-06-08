import 'customer_log.dart';

class Customer {
  final String id;
  String name;
  String email;
  String phone;
  List<CustomerLog> logs;

  Customer(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      List<CustomerLog>? logs})
      : logs = logs ?? [];

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        logs: (json['logs'] as List?)
                ?.map((l) => CustomerLog.fromJson(l))
                .toList() ??
            [],
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'logs': logs.map((l) => l.toJson()).toList(),
      };
}
