import 'dart:math';

import 'package:genfive/src/core/services/intel/response/intel_response.dart';

class Intel {
  static Stream<IntelResponse> fetchResponse(String query) async* {
    yield IntelFetchResponseInitialResponse();
    int startIndex = 0;
    String str = 'This is a response from Agent';
    while (startIndex < str.length) {
      int endIndex = Random().nextInt(5) + 1 + startIndex;
      if (endIndex > str.length) {
        endIndex = str.length;
      }
      yield IntelFetchResponseFetchingResponse(str.substring(startIndex, endIndex));
      startIndex = endIndex;
      int duration = Random().nextInt(300) + 200;
      await Future.delayed(Duration(milliseconds: duration));
    }
    yield IntelFetchResponseFetchedResponse();
    return;
  }
}