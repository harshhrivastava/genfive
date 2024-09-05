import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
    List<String> keys = homeUi.sessions?.keys.toList(growable: true) ?? List<String>.empty(growable: true);
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: const Color(0xFF212121),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            );
          }
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        backgroundColor: const Color(0xFF212121),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SessionButton(
                  icon: Icons.add,
                  text: 'Create New Chat',
                  onPressed: () {
                    setState(() {
                      homeUi.currentSessionId = null;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Divider(
                    color: Color(0xFF2f2f2f),
                    height: 1,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      return SessionButton(
                        text: 'Session $index',
                        onPressed: () {
                          if(keys[index] != homeUi.currentSessionId) {
                            setState(() {
                              homeUi.currentSessionId = keys[index];
                            });
                            Navigator.of(context).pop();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                homeUi.bodyScrollController.jumpTo(homeUi.bodyScrollController.position.maxScrollExtent);
                              });
                            });
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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

class SessionButton extends StatelessWidget {
  final IconData? icon;
  final String text;
  final void Function() onPressed;

  const SessionButton({
    super.key,
    this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xFF2f2f2f)),
        overlayColor: WidgetStatePropertyAll(Color(0xFF676767)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(icon != null)
            Icon(
              icon,
              color: Colors.white,
              size: 20.0,
            ),
          const SizedBox(width: 8.0),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}