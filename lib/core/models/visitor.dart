class Visitor {
  final String id;
  final String userId; // User who created the visitor entry
  final String name;
  final String purpose; // Visit purpose
  final DateTime expectedArrivalTime;
  final DateTime? actualArrivalTime;
  final DateTime? departureTime;
  final String status; // pending, arrived, departed, cancelled
  final String? vehiclePlate;
  final String? idNumber;
  final String? phone;
  final String? notes;
  final String? qrCode;

  Visitor({
    required this.id,
    required this.userId,
    required this.name,
    required this.purpose,
    required this.expectedArrivalTime,
    this.actualArrivalTime,
    this.departureTime,
    required this.status,
    this.vehiclePlate,
    this.idNumber,
    this.phone,
    this.notes,
    this.qrCode,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      purpose: json['purpose'],
      expectedArrivalTime: DateTime.parse(json['expectedArrivalTime']),
      actualArrivalTime: json['actualArrivalTime'] != null
          ? DateTime.parse(json['actualArrivalTime'])
          : null,
      departureTime: json['departureTime'] != null
          ? DateTime.parse(json['departureTime'])
          : null,
      status: json['status'],
      vehiclePlate: json['vehiclePlate'],
      idNumber: json['idNumber'],
      phone: json['phone'],
      notes: json['notes'],
      qrCode: json['qrCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'purpose': purpose,
      'expectedArrivalTime': expectedArrivalTime.toIso8601String(),
      'actualArrivalTime': actualArrivalTime?.toIso8601String(),
      'departureTime': departureTime?.toIso8601String(),
      'status': status,
      'vehiclePlate': vehiclePlate,
      'idNumber': idNumber,
      'phone': phone,
      'notes': notes,
      'qrCode': qrCode,
    };
  }

  Visitor copyWith({
    String? id,
    String? userId,
    String? name,
    String? purpose,
    DateTime? expectedArrivalTime,
    DateTime? actualArrivalTime,
    DateTime? departureTime,
    String? status,
    String? vehiclePlate,
    String? idNumber,
    String? phone,
    String? notes,
    String? qrCode,
  }) {
    return Visitor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      expectedArrivalTime: expectedArrivalTime ?? this.expectedArrivalTime,
      actualArrivalTime: actualArrivalTime ?? this.actualArrivalTime,
      departureTime: departureTime ?? this.departureTime,
      status: status ?? this.status,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      idNumber: idNumber ?? this.idNumber,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}
