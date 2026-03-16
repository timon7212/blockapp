class RegisterDeviceRequest {
  final String platform; // ios | android
  final String pushToken;

  const RegisterDeviceRequest({
    required this.platform,
    required this.pushToken,
  });

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'pushToken': pushToken,
      };
}

class DeviceResponseDto {
  final String deviceId;
  final String platform;
  final bool registered;

  const DeviceResponseDto({
    required this.deviceId,
    required this.platform,
    required this.registered,
  });

  factory DeviceResponseDto.fromJson(Map<String, dynamic> json) =>
      DeviceResponseDto(
        deviceId: json['deviceId'] as String,
        platform: json['platform'] as String,
        registered: json['registered'] as bool,
      );
}
