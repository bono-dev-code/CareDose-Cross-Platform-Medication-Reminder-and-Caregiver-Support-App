import 'dart:math';

class EncouragementService {
  final List<String> _messages = [
    'You are doing well. One small step at a time.',
    'Your health journey matters. Keep going.',
    'You are not alone. Stay strong and consistent.',
    'Taking care of yourself today protects your tomorrow.',
    'Well done for showing up for your health.',
  ];

  String getRandomMessage() {
    return _messages[Random().nextInt(_messages.length)];
  }
}
