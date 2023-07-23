import 'package:dio/dio.dart';
import 'package:events_time_microapp_dependencies/src/requesting/http_method.dart';
import 'package:events_time_microapp_dependencies/src/requesting/response_model.dart';

abstract class IRequesting {
  Future<RequestingResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
  });
  Future<RequestingResponse<dynamic>> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
  });
  Future<RequestingResponse<dynamic>> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
  });
  Future<RequestingResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
  });
}

class Requesting implements IRequesting {
  late String baseUrl;
  final Dio dio = Dio();

  Requesting({required this.baseUrl});

  Future<RequestingResponse<dynamic>> _request(
    String path, {
    required HttpMethod httpMethod,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    final Response<dynamic> response = await dio.request(
      (isFullPath ? '' : baseUrl) + path,
      queryParameters: queryParameters,
      data: body,
      options: Options(
        method: httpMethod.method,
        headers: header,
      ),
    );

    return RequestingResponse<dynamic>(
      response.statusCode ?? 500,
      response.realUri.toString(),
      response.data,
      response.headers.map,
    );
  }

  @override
  Future<RequestingResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    return _request(
      path,
      queryParameters: queryParameters,
      body: body,
      header: header,
      httpMethod: HttpMethod.DELETE,
      isFullPath: isFullPath,
    );
  }

  @override
  Future<RequestingResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    return _request(
      path,
      queryParameters: queryParameters,
      body: body,
      header: header,
      httpMethod: HttpMethod.GET,
      isFullPath: isFullPath,
    );
  }

  @override
  Future<RequestingResponse<dynamic>> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    return _request(
      path,
      queryParameters: queryParameters,
      body: body,
      header: header,
      httpMethod: HttpMethod.POST,
      isFullPath: isFullPath,
    );
  }

  @override
  Future<RequestingResponse<dynamic>> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? header,
    bool isFullPath = false,
  }) async {
    return _request(
      path,
      queryParameters: queryParameters,
      body: body,
      header: header,
      httpMethod: HttpMethod.PUT,
      isFullPath: isFullPath,
    );
  }
}
