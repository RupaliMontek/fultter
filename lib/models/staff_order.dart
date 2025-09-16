class StaffOrder {
  final int? id;
  final String staffName;
  final String item;
  final int quantity;
  final DateTime orderDate;

  const StaffOrder({
    this.id,
    required this.staffName,
    required this.item,
    required this.quantity,
    required this.orderDate,
  });

  StaffOrder copyWith({
    int? id,
    String? staffName,
    String? item,
    int? quantity,
    DateTime? orderDate,
  }) {
    return StaffOrder(
      id: id ?? this.id,
      staffName: staffName ?? this.staffName,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      orderDate: orderDate ?? this.orderDate,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'staff_name': staffName,
      'item': item,
      'quantity': quantity,
      'order_date': orderDate.millisecondsSinceEpoch,
    };
  }

  static StaffOrder fromMap(Map<String, Object?> map) {
    return StaffOrder(
      id: map['id'] as int?,
      staffName: map['staff_name'] as String,
      item: map['item'] as String,
      quantity: map['quantity'] as int,
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['order_date'] as int),
    );
  }
}

