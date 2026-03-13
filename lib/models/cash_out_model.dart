enum CashOutStatus {
  pending('Pending'),
  processing('Processing'),
  completed('Completed'),
  failed('Failed');

  final String label;
  const CashOutStatus(this.label);
}

class CashOutRequest {
  final String id;
  final String method;
  final String destination;
  final int pointsAmount;
  final CashOutStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const CashOutRequest({
    required this.id,
    required this.method,
    required this.destination,
    required this.pointsAmount,
    this.status = CashOutStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  CashOutRequest copyWith({
    String? method,
    String? destination,
    int? pointsAmount,
    CashOutStatus? status,
    DateTime? completedAt,
  }) {
    return CashOutRequest(
      id: id,
      method: method ?? this.method,
      destination: destination ?? this.destination,
      pointsAmount: pointsAmount ?? this.pointsAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
