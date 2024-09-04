import 'dart:math';

class Intel {
  static Future<String> fetchResponse(String query) async {
    int randomInteger = Random().nextInt(10) + 1;
    await Future.delayed(
      Duration(seconds: randomInteger)
    );
    return 'This is a response from Agent';
  }
}