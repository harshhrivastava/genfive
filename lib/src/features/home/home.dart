import 'package:flutter/material.dart';
import 'package:genfive/src/core/services/intel/intel.dart';
import 'package:genfive/src/features/home/models/home_ui.dart';
import 'package:genfive/src/features/home/models/message.dart';
import 'package:genfive/src/features/home/models/session.dart';
import 'package:genfive/src/features/home/widgets/chat_input_field.dart';
import 'package:genfive/src/features/home/widgets/chat_list_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String text = '';
  HomeUi homeUi = HomeUi();
  bool loading = false;

  void _createNewSession() {
    Session session = Session();
    homeUi.currentSessionId = session.sessionId;
    homeUi.sessions![session.sessionId] = session;
  }

  Future<void> _onQuerySubmitted() async {
    String query = text.toString();
    homeUi.sessions ??= <String, Session>{};
    if(homeUi.currentSessionId == null) _createNewSession();
    homeUi.sessions![homeUi.currentSessionId]!.messages ??= List<Message>.empty(growable: true);
    Message userQuery = Message.fromType(MessageType.user, query);
    setState(() {
      loading = true;
      homeUi.sessions![homeUi.currentSessionId]!.messages!.add(userQuery);
      _textEditingController.text = '';
      text = '';
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    String queryResponse = await Intel.fetchResponse(query);
    if(queryResponse.isNotEmpty) {
      Message agentResponse = Message.fromType(MessageType.agent, queryResponse);
      setState(() {
        loading = false;
        homeUi.sessions![homeUi.currentSessionId]!.messages!.add(agentResponse);
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  void _onQueryChanged(String newText) {
    setState(() {
      text = newText;
    });
  }

  void _onQuerySubmittedUsingKeyboard(String string) {
    if(_textEditingController.text != '' && !loading) {
      _onQuerySubmitted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 540.0,
            ),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ChatListView(
                  controller: _scrollController,
                  currentSessionId: homeUi.currentSessionId,
                  sessions: homeUi.sessions,
                ),
                ChatInputField(
                  controller: _textEditingController,
                  text: text,
                  loading: loading,
                  onQuerySubmitted: _onQuerySubmitted,
                  onQuerySubmittedUsingKeyboard: _onQuerySubmittedUsingKeyboard,
                  onQueryChanged: _onQueryChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}