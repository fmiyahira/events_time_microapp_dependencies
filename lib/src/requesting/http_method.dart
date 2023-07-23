enum HttpMethod {
  GET('GET'),
  POST('POST'),
  PUT('PUT'),
  DELETE('DELETE');

  final String method;
  const HttpMethod(this.method);
}
