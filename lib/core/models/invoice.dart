class Invoice {
  final String id;
  final String userId;
  final double amount;
  final DateTime dueDate;
  final DateTime issueDate;
  final String status; // pending, paid, overdue, cancelled
  final String invoiceType; // maintenance_fee, special_assessment, etc.
  final String? paymentId;
  final List<InvoiceItem> items;
  final String? notes;

  Invoice({
    required this.id,
    required this.userId,
    required this.amount,
    required this.dueDate,
    required this.issueDate,
    required this.status,
    required this.invoiceType,
    this.paymentId,
    required this.items,
    this.notes,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      issueDate: DateTime.parse(json['issueDate']),
      status: json['status'],
      invoiceType: json['invoiceType'],
      paymentId: json['paymentId'],
      items: (json['items'] as List).map((item) => InvoiceItem.fromJson(item)).toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'issueDate': issueDate.toIso8601String(),
      'status': status,
      'invoiceType': invoiceType,
      'paymentId': paymentId,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }

  Invoice copyWith({
    String? id,
    String? userId,
    double? amount,
    DateTime? dueDate,
    DateTime? issueDate,
    String? status,
    String? invoiceType,
    String? paymentId,
    List<InvoiceItem>? items,
    String? notes,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      issueDate: issueDate ?? this.issueDate,
      status: status ?? this.status,
      invoiceType: invoiceType ?? this.invoiceType,
      paymentId: paymentId ?? this.paymentId,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate) && status == 'pending';
}

class InvoiceItem {
  final String id;
  final String description;
  final double amount;
  final int quantity;
  final double totalAmount;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.quantity,
    required this.totalAmount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      quantity: json['quantity'],
      totalAmount: json['totalAmount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'totalAmount': totalAmount,
    };
  }
}
