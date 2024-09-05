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
  HomeUi homeUi = HomeUi();

  void _createNewSession() {
    Session session = Session();
    homeUi.currentSessionId = session.sessionId;
    homeUi.sessions![session.sessionId] = session;
  }

  Future<void> _onQuerySubmitted() async {
    String query = homeUi.text.toString();
    homeUi.sessions ??= <String, Session>{};
    if(homeUi.currentSessionId == null) _createNewSession();
    homeUi.sessions![homeUi.currentSessionId]!.messages ??= List<Message>.empty(growable: true);
    Message userQuery = Message.fromType(MessageType.user, query);
    setState(() {
      homeUi.loading = true;
      homeUi.sessions![homeUi.currentSessionId]!.messages!.add(userQuery);
      homeUi.textEditingController.text = '';
      homeUi.text = '';
      homeUi.bodyScrollController.jumpTo(homeUi.bodyScrollController.position.maxScrollExtent);
    });
    String queryResponse = await Intel.fetchResponse(query);
    if(queryResponse.isNotEmpty) {
      Message agentResponse = Message.fromType(MessageType.agent, queryResponse);
      setState(() {
        homeUi.loading = false;
        homeUi.sessions![homeUi.currentSessionId]!.messages!.add(agentResponse);
        homeUi.bodyScrollController.jumpTo(homeUi.bodyScrollController.position.maxScrollExtent);
      });
    } else {
      setState(() {
        homeUi.loading = false;
      });
    }
  }

  void _onQueryChanged(String newText) {
    setState(() {
      homeUi.text = newText;
    });
  }

  void _onQuerySubmittedUsingKeyboard(String string) {
    if(homeUi.textEditingController.text != '' && !homeUi.loading) {
      _onQuerySubmitted();
    }
  }

  Widget _buildWebView([bool extended = true]) {
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
                  controller: homeUi.bodyScrollController,
                  currentSessionId: homeUi.currentSessionId,
                  sessions: homeUi.sessions,
                ),
                ChatInputField(
                  controller: homeUi.textEditingController,
                  text: homeUi.text,
                  loading: homeUi.loading,
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

  Widget _buildMobileView() {
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
                  controller: homeUi.bodyScrollController,
                  currentSessionId: homeUi.currentSessionId,
                  sessions: homeUi.sessions,
                ),
                ChatInputField(
                  controller: homeUi.textEditingController,
                  text: homeUi.text,
                  loading: homeUi.loading,
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

  @override
  Widget build(BuildContext context) {
    Widget child;
    if(MediaQuery.of(context).size.width > 600) {
      if(MediaQuery.of(context).size.width > 720) {
        child = _buildWebView(false);
      } else {
        child = _buildWebView();
      }
    } else {
      child = _buildMobileView();
    }
    return child;
  }
}