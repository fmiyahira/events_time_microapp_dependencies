import 'package:events_time_microapp_dependencies/src/requesting/http_method.dart';

abstract class RequestingRequest {
  String get path;
  HttpMethod get httpMethod;
  Map<String, dynamic> get headers;
  Map<String, dynamic> get body;
  Map<String, dynamic> get queryParameters;
}
