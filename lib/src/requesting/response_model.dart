// ignore_for_file: public_member_api_docs, sort_constructors_first
class RequestingResponse<T> {
  final int statusCode;
  final String url;
  final T body;
  final Map<String, dynamic> header;

  RequestingResponse(
    this.statusCode,
    this.url,
    this.body,
    this.header,
  );

  @override
  String toString() {
    return '''
Response:
$statusCode $url
- Body: $body
- Header: $header
''';
  }
}
