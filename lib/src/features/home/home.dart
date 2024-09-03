import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _textEditingController = TextEditingController();
  String text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 0,
              itemBuilder: (context, index) {
                // TODO: Create Message Widget
                return Container();
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
                  onPressed: () {},
                  color: Colors.black,
                  icon: Container(
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
    );
  }
}