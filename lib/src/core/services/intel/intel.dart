import 'dart:math';

class Intel {
  Future<String> fetchResponse() async {
    int randomInteger = Random().nextInt(10) + 1;
    await Future.delayed(
      Duration(seconds: randomInteger)
    );
    return 'This is a response';
  }
}