import 'package:uuid/uuid.dart';

enum MessageType {
  user,
  agent;
}

abstract class Message {
  final String messageId;
  final DateTime createdAt;
  final String message;

  Message(this.message)
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
  UserMessage(super.message);
}

class AgentMessage extends Message {
  AgentMessage(super.message);
}