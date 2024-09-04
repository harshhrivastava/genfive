import 'package:flutter/material.dart';
import 'package:genfive/src/core/services/intel/intel.dart';
import 'package:genfive/src/features/home/models/home_ui.dart';
import 'package:genfive/src/features/home/models/message.dart';
import 'package:genfive/src/features/home/models/session.dart';
import 'package:genfive/src/features/home/widgets/agent_message.dart';
import 'package:genfive/src/features/home/widgets/user_message.dart';

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

  Future<void> _submitQuery() async {
    String query = text.toString();
    homeUi.sessions ??= <String, Session>{};
    if(homeUi.currentSessionId == null) {
      Session session = Session();
      homeUi.currentSessionId = session.sessionId;
      homeUi.sessions![session.sessionId] = session;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 720.0,
          ),
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: homeUi.currentSessionId == null || homeUi.sessions == null || !homeUi.sessions!.containsKey(homeUi.currentSessionId) || homeUi.sessions![homeUi.currentSessionId]!.messages == null
                      ? 0
                      : homeUi.sessions![homeUi.currentSessionId]!.messages!.length,
                  itemBuilder: (context, index) {
                    if(homeUi.sessions![homeUi.currentSessionId]!.messages![index].runtimeType == UserMessage) {
                      return UserMessageWidget(homeUi.sessions![homeUi.currentSessionId]!.messages![index].message);
                    } else {
                      return AgentMessageWidget(homeUi.sessions![homeUi.currentSessionId]!.messages![index].message);
                    }
                  },
                ),
              ),
              Container(
                height: 64,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(64.0),
                  color: const Color(0xFF2f2f2f),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24),
                    Expanded(
                      child: Center(
                        child: TextField(
                          controller: _textEditingController,
                          onChanged: (String newText) {
                            setState(() {
                              text = newText;
                            });
                          },
                          onSubmitted: (String string) {
                            if(_textEditingController.text != '' && !loading) {
                              _submitQuery();
                            }
                          },
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                          cursorColor: Colors.white,
                          decoration: const InputDecoration.collapsed(
                            hintText: "Message Agent",
                            hintStyle: TextStyle(
                              color: Color(0xFF676767),
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: text.isNotEmpty && !loading
                          ? _submitQuery
                          : null,
                      color: Colors.black,
                      style: const ButtonStyle(
                        surfaceTintColor: null,
                        overlayColor: null,
                        shadowColor: null,
                      ),
                      icon: loading
                          ? const SizedBox(
                            height: 32,
                            width: 32,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                            ),
                          )
                          : Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: text.isEmpty
                                  ? const Color(0xFF676767)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.keyboard_arrow_right,
                                size: 24,
                                color: Color(0xFF2e2e2e),
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}