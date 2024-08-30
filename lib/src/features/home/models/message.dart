import 'package:uuid/uuid.dart';

enum MessageType {
  user,
  agent;
}

abstract class Message {
  final String messageId;
  final DateTime createdAt;

  Message()
    : messageId = const Uuid().v4(),
      createdAt = DateTime.now();

  factory Message.fromType(MessageType type, String message) {
    switch(type) {
      case MessageType.user:
        return UserMessage(message);
      case MessageType.agent:
        return AgentMessage(message);
    }
  }
}

class UserMessage extends Message {
  final String message;
  UserMessage(this.message);
}

class AgentMessage extends Message {
  final String message;
  AgentMessage(this.message);
}