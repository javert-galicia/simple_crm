enum LogType { telefono, email, whatsapp, redSocial }

enum LogRating { bueno, regular, malo }

class CustomerLog {
  final String id;
  final LogType type;
  final String message;
  final DateTime date;
  bool isDone;
  final LogRating rating;

  CustomerLog({
    required this.id,
    required this.type,
    required this.message,
    required this.date,
    this.isDone = false,
    required this.rating,
  });

  factory CustomerLog.fromJson(Map<String, dynamic> json) => CustomerLog(
        id: json['id'],
        type: LogType.values.firstWhere((e) => e.toString() == json['type']),
        message: json['message'],
        date: DateTime.parse(json['date']),
        isDone: json['isDone'] ?? false,
        rating: LogRating.values.firstWhere((e) => e.toString() == json['rating']),
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'message': message,
        'date': date.toIso8601String(),
        'isDone': isDone,
        'rating': rating.toString(),
      };
}
