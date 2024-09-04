import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final bool loading;
  final Future<void> Function() onQuerySubmitted;
  final void Function(String) onQuerySubmittedUsingKeyboard;
  final void Function(String) onQueryChanged;

  const ChatInputField({
    super.key,
    required this.loading,
    required this.text,
    required this.onQuerySubmittedUsingKeyboard,
    required this.onQuerySubmitted,
    required this.onQueryChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                controller: controller,
                onChanged: onQueryChanged,
                onSubmitted: onQuerySubmittedUsingKeyboard,
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
                ? onQuerySubmitted
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
    );
  }
}