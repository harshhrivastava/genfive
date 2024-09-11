// ignore_for_file: type_literal_in_constant_pattern

import 'dart:convert';

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
    Stream<List<int>> queryResponseStream = await Intel.fetchQueryResponse(query);
    bool firstResponse = true;
    queryResponseStream.listen((chunk) {
      if(firstResponse) {
        firstResponse = false;
        Message agentResponse = Message.fromType(MessageType.agent, "");
        setState(() {
          homeUi.sessions![homeUi.currentSessionId]!.messages!.add(agentResponse);
          homeUi.bodyScrollController.jumpTo(homeUi.bodyScrollController.position.maxScrollExtent);
        });
      }
      final raw = String.fromCharCodes(chunk);
      final unparsed = raw.split('\n');
      for(int i = 0; i < unparsed.length; i++) {
        if(unparsed[i].isNotEmpty) {
          int start = unparsed[i].indexOf("{");
          int end = unparsed[i].lastIndexOf("}");
          if (start != -1 && end != -1 && start < end) {
            String jsonString = unparsed[i].substring(start, end + 1);
            Map<String, dynamic> json;
            try {
              json = jsonDecode(jsonString);
            } on Exception catch (_) {
              if(jsonString.contains('"choices"')) {
                jsonString = jsonString.replaceFirst(",", '{');
              } else {
                jsonString = jsonString.replaceFirst(",", '{"choices":[{');
              }
              jsonString = jsonString.substring(jsonString.indexOf("{"), jsonString.length);
              try {
                json = jsonDecode(jsonString);
              } on Exception catch (_) {
                continue;
              }
            }
            String? content = json['choices'][0]['delta']['content'];
            if(content != null && content.isNotEmpty) {
              setState(() {
                homeUi.sessions![homeUi.currentSessionId]!.messages!.last.message += content;
                homeUi.bodyScrollController.jumpTo(homeUi.bodyScrollController.position.maxScrollExtent);
              });
            }
          }
        }
      }
    });
    await queryResponseStream;
    setState(() {
      homeUi.loading = false;
      homeUi.bodyScrollController.jumpTo(homeUi.bodyScrollController.position.maxScrollExtent);
    });
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
    List<String> keys = homeUi.sessions?.keys.toList(growable: true) ?? List<String>.empty(growable: true);
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 720,
            decoration: const BoxDecoration(
              color: Color(0xFF171717),
            ),
            constraints: const BoxConstraints(
              maxWidth: 270,
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
                      active: homeUi.currentSessionId == null,
                      onPressed: () {
                        if(homeUi.currentSessionId != null) {
                          setState(() {
                            homeUi.currentSessionId = null;
                          });
                        }
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
                            active: homeUi.currentSessionId == keys[index],
                            onPressed: () {
                              if(keys[index] != homeUi.currentSessionId) {
                                setState(() {
                                  homeUi.currentSessionId = keys[index];
                                });
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  setState(() {
                                    homeUi.bodyScrollController.jumpTo(homeUi.bodyScrollController.position.maxScrollExtent);
                                  });
                                });
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
          Expanded(
            child: SafeArea(
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
          ),
        ],
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
        backgroundColor: const Color(0xFF171717),
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
    if(MediaQuery.of(context).size.width > 970) {
      child = _buildWebView(false);
    } else {
      child = _buildMobileView();
    }
    return child;
  }
}

class SessionButton extends StatelessWidget {
  final IconData? icon;
  final String text;
  final bool active;
  final void Function() onPressed;

  const SessionButton({
    super.key,
    this.icon,
    this.active = false,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: active ? const WidgetStatePropertyAll(Color(0xFF2f2f2f)) : null,
        overlayColor: const WidgetStatePropertyAll(Color(0xFF676767)),
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