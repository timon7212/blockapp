import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/user_model.dart';

class ExerciseDetectionService {
  final ExerciseType exerciseType;
  final PoseDetector _poseDetector;

  int _repCount = 0;
  bool _inDownPosition = false;

  static const double _pushUpDownAngle = 90.0;
  static const double _pushUpUpAngle = 150.0;
  static const double _squatDownAngle = 100.0;
  static const double _squatUpAngle = 160.0;
  static const double _sitUpDownAngle = 150.0;
  static const double _sitUpUpAngle = 90.0;

  ExerciseDetectionService({required this.exerciseType})
      : _poseDetector = PoseDetector(
          options: PoseDetectorOptions(
            mode: PoseDetectionMode.stream,
          ),
        );

  int get repCount => _repCount;

  Future<int> processFrame(InputImage inputImage) async {
    final poses = await _poseDetector.processImage(inputImage);
    if (poses.isEmpty) return _repCount;

    final pose = poses.first;

    switch (exerciseType) {
      case ExerciseType.pushUps:
        _detectPushUp(pose);
      case ExerciseType.squats:
        _detectSquat(pose);
      case ExerciseType.sitUps:
        _detectSitUp(pose);
    }

    return _repCount;
  }

  void _detectPushUp(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    if (leftShoulder == null || leftElbow == null || leftWrist == null) return;

    final angle = _angleBetween(leftShoulder, leftElbow, leftWrist);

    if (!_inDownPosition && angle < _pushUpDownAngle) {
      _inDownPosition = true;
    } else if (_inDownPosition && angle > _pushUpUpAngle) {
      _inDownPosition = false;
      _repCount++;
    }
  }

  void _detectSquat(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (leftHip == null || leftKnee == null || leftAnkle == null) return;

    final angle = _angleBetween(leftHip, leftKnee, leftAnkle);

    if (!_inDownPosition && angle < _squatDownAngle) {
      _inDownPosition = true;
    } else if (_inDownPosition && angle > _squatUpAngle) {
      _inDownPosition = false;
      _repCount++;
    }
  }

  void _detectSitUp(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (leftShoulder == null || leftHip == null || leftKnee == null) return;

    final angle = _angleBetween(leftShoulder, leftHip, leftKnee);

    if (!_inDownPosition && angle < _sitUpUpAngle) {
      _inDownPosition = true;
    } else if (_inDownPosition && angle > _sitUpDownAngle) {
      _inDownPosition = false;
      _repCount++;
    }
  }

  double _angleBetween(
    PoseLandmark a,
    PoseLandmark b,
    PoseLandmark c,
  ) {
    final ab = Point<double>(a.x - b.x, a.y - b.y);
    final cb = Point<double>(c.x - b.x, c.y - b.y);

    final dot = ab.x * cb.x + ab.y * cb.y;
    final magAB = sqrt(ab.x * ab.x + ab.y * ab.y);
    final magCB = sqrt(cb.x * cb.x + cb.y * cb.y);

    if (magAB == 0 || magCB == 0) return 180.0;

    final cosAngle = (dot / (magAB * magCB)).clamp(-1.0, 1.0);
    return acos(cosAngle) * 180.0 / pi;
  }

  void reset() {
    _repCount = 0;
    _inDownPosition = false;
  }

  void dispose() {
    _poseDetector.close();
  }
}
