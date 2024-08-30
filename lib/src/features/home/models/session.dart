import 'package:genfive/src/features/home/models/message.dart';
import 'package:uuid/uuid.dart';

class Session {
  final String sessionId;
  List<Message>? messages;

  Session() : sessionId = const Uuid().v4();
}