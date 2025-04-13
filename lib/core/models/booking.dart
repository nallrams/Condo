class Booking {
  final String id;
  final String facilityId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // pending, confirmed, cancelled, completed
  final double totalAmount;
  final String? paymentId;
  final DateTime createdAt;
  final String? notes;
  final int? numberOfGuests;

  Booking({
    required this.id,
    required this.facilityId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
    this.paymentId,
    required this.createdAt,
    this.notes,
    this.numberOfGuests,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      facilityId: json['facilityId'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'],
      totalAmount: json['totalAmount'].toDouble(),
      paymentId: json['paymentId'],
      createdAt: DateTime.parse(json['createdAt']),
      notes: json['notes'],
      numberOfGuests: json['numberOfGuests'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityId': facilityId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'totalAmount': totalAmount,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'numberOfGuests': numberOfGuests,
    };
  }

  Booking copyWith({
    String? id,
    String? facilityId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    double? totalAmount,
    String? paymentId,
    DateTime? createdAt,
    String? notes,
    int? numberOfGuests,
  }) {
    return Booking(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
    );
  }

  int get durationInHours => endTime.difference(startTime).inHours;
}
