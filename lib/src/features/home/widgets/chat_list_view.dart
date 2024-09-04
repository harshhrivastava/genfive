import 'package:flutter/material.dart';
import 'package:genfive/src/features/home/models/message.dart';
import 'package:genfive/src/features/home/models/session.dart';
import 'package:genfive/src/features/home/widgets/agent_message.dart';
import 'package:genfive/src/features/home/widgets/user_message.dart';

class ChatListView extends StatelessWidget {
  final ScrollController controller;
  final String? currentSessionId;
  final Map<String, Session>? sessions;

  const ChatListView({
    super.key,
    required this.currentSessionId,
    required this.sessions,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: controller,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: currentSessionId == null || sessions == null || !sessions!.containsKey(currentSessionId) || sessions![currentSessionId]!.messages == null
            ? 0
            : sessions![currentSessionId]!.messages!.length,
        itemBuilder: (context, index) {
          if(sessions![currentSessionId]!.messages![index].runtimeType == UserMessage) {
            return UserMessageWidget(sessions![currentSessionId]!.messages![index].message);
          } else {
            return AgentMessageWidget(sessions![currentSessionId]!.messages![index].message);
          }
        },
      ),
    );
  }
}