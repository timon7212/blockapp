class BlockedAppModel {
  final String id;
  final String name;
  final String iconEmoji;
  final bool isBlocked;
  final bool isActive;

  const BlockedAppModel({
    required this.id,
    required this.name,
    required this.iconEmoji,
    this.isBlocked = true,
    this.isActive = true,
  });

  BlockedAppModel copyWith({bool? isBlocked, bool? isActive}) {
    return BlockedAppModel(
      id: id,
      name: name,
      iconEmoji: iconEmoji,
      isBlocked: isBlocked ?? this.isBlocked,
      isActive: isActive ?? this.isActive,
    );
  }
}

List<BlockedAppModel> defaultBlockableApps() => const [
  BlockedAppModel(id: 'instagram', name: 'Instagram', iconEmoji: '📷'),
  BlockedAppModel(id: 'tiktok', name: 'TikTok', iconEmoji: '🎵'),
  BlockedAppModel(id: 'youtube', name: 'YouTube', iconEmoji: '▶️'),
  BlockedAppModel(id: 'twitter', name: 'X (Twitter)', iconEmoji: '🐦'),
  BlockedAppModel(id: 'snapchat', name: 'Snapchat', iconEmoji: '👻'),
  BlockedAppModel(id: 'reddit', name: 'Reddit', iconEmoji: '🤖'),
  BlockedAppModel(id: 'facebook', name: 'Facebook', iconEmoji: '📘'),
  BlockedAppModel(id: 'threads', name: 'Threads', iconEmoji: '🧵'),
];
