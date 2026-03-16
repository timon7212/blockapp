class CharityDto {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String color;

  const CharityDto({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
  });

  factory CharityDto.fromJson(Map<String, dynamic> json) => CharityDto(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        description: json['description'] as String,
        color: json['color'] as String,
      );
}

class DonateRequest {
  final int amount;

  const DonateRequest({required this.amount});

  Map<String, dynamic> toJson() => {'amount': amount};
}

class DonationResponseDto {
  final bool success;
  final String donationId;
  final int amount;
  final String charityName;
  final int newBalance;

  const DonationResponseDto({
    required this.success,
    required this.donationId,
    required this.amount,
    required this.charityName,
    required this.newBalance,
  });

  factory DonationResponseDto.fromJson(Map<String, dynamic> json) =>
      DonationResponseDto(
        success: json['success'] as bool,
        donationId: json['donationId'] as String,
        amount: (json['amount'] as num).toInt(),
        charityName: json['charityName'] as String,
        newBalance: (json['newBalance'] as num).toInt(),
      );
}
