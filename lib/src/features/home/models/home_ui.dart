import 'package:flutter/material.dart';
import 'package:genfive/src/features/home/models/session.dart';

class HomeUi {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController bodyScrollController = ScrollController();
  String text = '';
  bool loading = false;
  Map<String, Session>? sessions;
  String? currentSessionId;
  bool extendScreen = true;
}