class MissionModel {
  final String id;
  final String title;
  final String icon;
  final MissionType type;
  final bool completed;

  const MissionModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    this.completed = false,
  });

  MissionModel copyWith({bool? completed}) {
    return MissionModel(
      id: id,
      title: title,
      icon: icon,
      type: type,
      completed: completed ?? this.completed,
    );
  }
}

enum MissionType {
  exercise,
  watchAd,
  spinWheel,
  inviteFriend,
  completeTask,
}

List<MissionModel> defaultDailyMissions() => [
  const MissionModel(
    id: 'mission_exercise',
    title: 'Complete 1 exercise',
    icon: '💪',
    type: MissionType.exercise,
  ),
  const MissionModel(
    id: 'mission_ad',
    title: 'Watch 1 reward ad',
    icon: '🎬',
    type: MissionType.watchAd,
  ),
  const MissionModel(
    id: 'mission_spin',
    title: 'Spin the wheel',
    icon: '🎰',
    type: MissionType.spinWheel,
  ),
  const MissionModel(
    id: 'mission_invite',
    title: 'Invite a friend',
    icon: '👥',
    type: MissionType.inviteFriend,
  ),
  const MissionModel(
    id: 'mission_task',
    title: 'Complete a task or survey',
    icon: '📋',
    type: MissionType.completeTask,
  ),
];
