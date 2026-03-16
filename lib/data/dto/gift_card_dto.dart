class GiftCardImageDto {
  final String src;
  final String type;

  const GiftCardImageDto({required this.src, required this.type});

  factory GiftCardImageDto.fromJson(Map<String, dynamic> json) =>
      GiftCardImageDto(
        src: json['src'] as String,
        type: json['type'] as String,
      );
}

class GiftCardSkuDto {
  final double min;
  final double max;

  const GiftCardSkuDto({required this.min, required this.max});

  factory GiftCardSkuDto.fromJson(Map<String, dynamic> json) => GiftCardSkuDto(
        min: (json['min'] as num).toDouble(),
        max: (json['max'] as num).toDouble(),
      );
}

class GiftCardDto {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? subcategory;
  final List<String> currencyCodes;
  final List<String> countries;
  final List<GiftCardImageDto> images;
  final List<GiftCardSkuDto> skus;
  final int? coinCost;

  const GiftCardDto({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.subcategory,
    required this.currencyCodes,
    required this.countries,
    required this.images,
    required this.skus,
    this.coinCost,
  });

  /// Get the best image URL (card_image first, then logo, then any).
  String? get imageUrl {
    final card =
        images.where((i) => i.type == 'card_image').firstOrNull;
    if (card != null) return card.src;
    final logo = images.where((i) => i.type == 'logo').firstOrNull;
    if (logo != null) return logo.src;
    return images.isNotEmpty ? images.first.src : null;
  }

  factory GiftCardDto.fromJson(Map<String, dynamic> json) => GiftCardDto(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        currencyCodes: (json['currencyCodes'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        countries: (json['countries'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        images: (json['images'] as List<dynamic>)
            .map((e) => GiftCardImageDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        skus: (json['skus'] as List<dynamic>)
            .map((e) => GiftCardSkuDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        coinCost: json['coinCost'] != null
            ? (json['coinCost'] as num).toInt()
            : null,
      );
}

class RedeemGiftCardRequest {
  final String productId;
  final double amount;
  final String? currency;

  const RedeemGiftCardRequest({
    required this.productId,
    required this.amount,
    this.currency,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'amount': amount,
        if (currency != null) 'currency': currency,
      };
}

class RedemptionResponseDto {
  final bool success;
  final String orderId;
  final String rewardId;
  final String? redemptionLink;
  final int coinsSpent;
  final int newBalance;

  const RedemptionResponseDto({
    required this.success,
    required this.orderId,
    required this.rewardId,
    this.redemptionLink,
    required this.coinsSpent,
    required this.newBalance,
  });

  factory RedemptionResponseDto.fromJson(Map<String, dynamic> json) =>
      RedemptionResponseDto(
        success: json['success'] as bool,
        orderId: json['orderId'] as String,
        rewardId: json['rewardId'] as String,
        redemptionLink: json['redemptionLink'] as String?,
        coinsSpent: (json['coinsSpent'] as num).toInt(),
        newBalance: (json['newBalance'] as num).toInt(),
      );
}

class RedemptionHistoryDto {
  final String id;
  final String orderId;
  final String productName;
  final double faceValue;
  final String currency;
  final int coinCost;
  final String? redemptionLink;
  final String status; // pending | delivered | failed
  final DateTime redeemedAt;

  const RedemptionHistoryDto({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.faceValue,
    required this.currency,
    required this.coinCost,
    this.redemptionLink,
    required this.status,
    required this.redeemedAt,
  });

  factory RedemptionHistoryDto.fromJson(Map<String, dynamic> json) =>
      RedemptionHistoryDto(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        productName: json['productName'] as String,
        faceValue: (json['faceValue'] as num).toDouble(),
        currency: json['currency'] as String,
        coinCost: (json['coinCost'] as num).toInt(),
        redemptionLink: json['redemptionLink'] as String?,
        status: json['status'] as String,
        redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      );
}
