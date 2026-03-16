class CashOutRequest {
  final int coinAmount;
  final String paymentMethod; // paypal | bank_transfer | crypto
  final String paymentDetails;

  const CashOutRequest({
    required this.coinAmount,
    required this.paymentMethod,
    required this.paymentDetails,
  });

  Map<String, dynamic> toJson() => {
        'coinAmount': coinAmount,
        'paymentMethod': paymentMethod,
        'paymentDetails': paymentDetails,
      };
}

class CashOutResponseDto {
  final bool success;
  final String cashOutId;
  final int coinAmount;
  final double cashValue;
  final int newBalance;
  final String status; // pending | processing | completed | failed

  const CashOutResponseDto({
    required this.success,
    required this.cashOutId,
    required this.coinAmount,
    required this.cashValue,
    required this.newBalance,
    required this.status,
  });

  factory CashOutResponseDto.fromJson(Map<String, dynamic> json) =>
      CashOutResponseDto(
        success: json['success'] as bool,
        cashOutId: json['cashOutId'] as String,
        coinAmount: (json['coinAmount'] as num).toInt(),
        cashValue: (json['cashValue'] as num).toDouble(),
        newBalance: (json['newBalance'] as num).toInt(),
        status: json['status'] as String,
      );
}

class CashOutHistoryDto {
  final String id;
  final int coinAmount;
  final double cashValue;
  final String paymentMethod;
  final String status;
  final DateTime requestedAt;
  final DateTime? completedAt;

  const CashOutHistoryDto({
    required this.id,
    required this.coinAmount,
    required this.cashValue,
    required this.paymentMethod,
    required this.status,
    required this.requestedAt,
    this.completedAt,
  });

  factory CashOutHistoryDto.fromJson(Map<String, dynamic> json) =>
      CashOutHistoryDto(
        id: json['id'] as String,
        coinAmount: (json['coinAmount'] as num).toInt(),
        cashValue: (json['cashValue'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] as String,
        status: json['status'] as String,
        requestedAt: DateTime.parse(json['requestedAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );
}
