import 'dart:math';

import 'package:flutter/material.dart';

class AgentMessageWidget extends StatelessWidget {
  final String text;

  const AgentMessageWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: min(MediaQuery.of(context).size.width * 0.8, 540),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0).copyWith(bottomRight: Radius.zero),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
