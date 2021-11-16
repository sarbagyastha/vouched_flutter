import 'package:flutter/painting.dart';

enum CardDetailStep {
  preDetected,
  detected,
  postable,
  unknown,
}

enum CardDetailInstruction {
  noCard,
  onlyOne,
  moveCloser,
  moveAway,
  glare,
  dark,
  blur,
  holdSteady,
  noFace,
  openMouth,
  closeMouth,
  lookForward,
  lookLeft,
  lookRight,
  blinkEyes,
  none,
}

class CardDetailResult {
  const CardDetailResult({
    required this.step,
    required this.instruction,
    required this.image,
    required this.location,
  });

  final CardDetailStep step;
  final CardDetailInstruction instruction;
  final String image;
  final Rect? location;

  factory CardDetailResult.fromMap(Map<String, dynamic> map) {
    final location = Map<String, double>.from(map['location'] ?? {});
    final instruction = _instructionsMap[map['instruction']];

    return CardDetailResult(
      step: _stepsMap[map['step']] ?? CardDetailStep.unknown,
      instruction: instruction ?? CardDetailInstruction.none,
      image: map['image'] ?? '',
      location: location.isEmpty
          ? null
          : Rect.fromLTRB(
              location['l'] ?? 0,
              location['t'] ?? 0,
              location['r'] ?? 0,
              location['b'] ?? 0,
            ),
    );
  }

  @override
  String toString() {
    return 'CardDetailResult{step: $step, instruction: $instruction, image: $image, location: $location}';
  }
}

const Map<String, CardDetailStep> _stepsMap = {
  'PRE_DETECTED': CardDetailStep.preDetected,
  'DETECTED': CardDetailStep.detected,
  'POSTABLE': CardDetailStep.postable,
};

const Map<String, CardDetailInstruction> _instructionsMap = {
  'NO_CARD': CardDetailInstruction.noCard,
  'ONLY_ONE': CardDetailInstruction.onlyOne,
  'MOVE_CLOSER': CardDetailInstruction.moveCloser,
  'MOVE_AWAY': CardDetailInstruction.moveAway,
  'GLARE': CardDetailInstruction.glare,
  'DARK': CardDetailInstruction.dark,
  'BLUR': CardDetailInstruction.blur,
  'HOLD_STEADY': CardDetailInstruction.holdSteady,
  'NO_FACE': CardDetailInstruction.noFace,
  'OPEN_MOUTH': CardDetailInstruction.openMouth,
  'CLOSE_MOUTH': CardDetailInstruction.closeMouth,
  'LOOK_FORWARD': CardDetailInstruction.lookForward,
  'LOOK_LEFT': CardDetailInstruction.lookLeft,
  'LOOK_RIGHT': CardDetailInstruction.lookRight,
  'BLINK_EYES': CardDetailInstruction.blinkEyes,
};
