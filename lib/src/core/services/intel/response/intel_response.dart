abstract class IntelResponse {}

final class IntelFetchResponseFetchingResponse extends IntelResponse {
  final String response;

  IntelFetchResponseFetchingResponse(this.response);
}

final class IntelFetchResponseFetchedResponse extends IntelResponse {}

final class IntelFetchResponseInitialResponse extends IntelResponse {}