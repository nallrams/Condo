class Payment {
  final String id;
  final String userId;
  final double amount;
  final String status; // pending, completed, failed, refunded
  final String paymentMethod; // credit_card, bank_transfer, etc.
  final DateTime paymentDate;
  final String referenceId; // Can be booking ID, invoice ID, etc.
  final String referenceType; // booking, invoice, etc.
  final Map<String, dynamic>? paymentDetails;
  final String? notes;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.paymentDate,
    required this.referenceId,
    required this.referenceType,
    this.paymentDetails,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      paymentDate: DateTime.parse(json['paymentDate']),
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      paymentDetails: json['paymentDetails'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'referenceId': referenceId,
      'referenceType': referenceType,
      'paymentDetails': paymentDetails,
      'notes': notes,
    };
  }

  Payment copyWith({
    String? id,
    String? userId,
    double? amount,
    String? status,
    String? paymentMethod,
    DateTime? paymentDate,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? paymentDetails,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      notes: notes ?? this.notes,
    );
  }
}
